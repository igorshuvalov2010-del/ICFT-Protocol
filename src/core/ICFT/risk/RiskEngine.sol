// SPDX-License-Identifier: GPL-3.0-only
pragma solidity ^0.8.20;

import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";

import {IPriceOracle} from "../../interfaces/IPriceOracle.sol";
import {IRiskEngine} from "../../interfaces/IRiskEngine.sol";
import {InvalidAddress, InvalidRiskParameters} from "../../utils/Errors.sol";

/**
 * @title RiskEngine
 * @notice Computes collateral value, borrow capacity, LTV, and liquidation sizing.
 * @dev All USD values in this contract use the protocol's internal 1e18 accounting unit.
 * @dev The engine is purely computational and depends on the oracle for ETH/USD valuation.
 * @dev Liquidation sizing attempts to move a position toward the configured target LTV while applying the bonus.
 *
 * @custom:version 1.0.0
 */
contract RiskEngine is IRiskEngine, AccessControl {
    /// @notice Role allowed to update risk parameters.
    bytes32 public constant RISK_ADMIN_ROLE = keccak256("RISK_ADMIN_ROLE");

    /// @notice Basis-point denominator used across risk calculations.
    uint256 public constant BPS = 10_000;

    /// @notice Oracle used to value ETH collateral in internal USD units.
    IPriceOracle public immutable priceOracle;

    /// @notice Maximum healthy borrow LTV in basis points.
    uint256 public maxLtvBps;
    /// @notice LTV threshold at or above which positions become liquidatable.
    uint256 public liquidationThresholdBps;
    /// @notice Post-liquidation LTV the engine attempts to restore.
    uint256 public targetLtvBps;
    /// @notice Liquidator bonus applied to seized collateral value.
    uint256 public liquidationBonusBps;

    /**
     * @notice Creates the risk engine with the initial LTV and liquidation configuration.
     * @param admin Address that receives admin and risk-admin roles.
     * @param priceOracle_ Oracle used for ETH/USD collateral valuation.
     * @param maxLtvBps_ Maximum healthy LTV in basis points.
     * @param liquidationThresholdBps_ Liquidation threshold in basis points.
     * @param targetLtvBps_ Target LTV in basis points.
     * @param liquidationBonusBps_ Liquidator bonus in basis points.
     */
    constructor(
        address admin,
        address priceOracle_,
        uint256 maxLtvBps_,
        uint256 liquidationThresholdBps_,
        uint256 targetLtvBps_,
        uint256 liquidationBonusBps_
    ) {
        if (admin == address(0) || priceOracle_ == address(0)) revert InvalidAddress();

        _grantRole(DEFAULT_ADMIN_ROLE, admin);
        _grantRole(RISK_ADMIN_ROLE, admin);

        // Persist external dependency before validating and storing parameter set.
        priceOracle = IPriceOracle(priceOracle_);
        _setRiskParameters(maxLtvBps_, liquidationThresholdBps_, targetLtvBps_, liquidationBonusBps_);
    }

    /// @inheritdoc IRiskEngine
    function getCollateralValueUSD(uint256 collateralAmount) public view returns (uint256) {
        return (collateralAmount * priceOracle.getETHUSDPrice()) / 1e18;
    }

    /// @inheritdoc IRiskEngine
    function getMaxBorrowUSD(uint256 collateralAmount) external view returns (uint256) {
        return (getCollateralValueUSD(collateralAmount) * maxLtvBps) / BPS;
    }

    /// @inheritdoc IRiskEngine
    function calculateLTV(uint256 collateralAmount, uint256 debtUSD) public view returns (uint256) {
        if (debtUSD == 0) return 0;

        uint256 collateralValueUSD = getCollateralValueUSD(collateralAmount);
        if (collateralValueUSD == 0) return type(uint256).max;

        return (debtUSD * BPS) / collateralValueUSD;
    }

    /// @inheritdoc IRiskEngine
    function isLiquidatable(uint256 collateralAmount, uint256 debtUSD) external view returns (bool) {
        return calculateLTV(collateralAmount, debtUSD) >= liquidationThresholdBps;
    }

    /// @inheritdoc IRiskEngine
    function calculateLiquidation(
        uint256 collateralAmount,
        uint256 debtUSD
    ) external view returns (LiquidationOutcome memory outcome) {
        uint256 collateralValueUSD = getCollateralValueUSD(collateralAmount);
        uint256 currentLtvBps = calculateLTV(collateralAmount, debtUSD);

        if (collateralValueUSD == 0 || debtUSD == 0 || currentLtvBps < liquidationThresholdBps) {
            return outcome;
        }

        uint256 target = targetLtvBps;
        uint256 bonus = liquidationBonusBps;

        uint256 lhs = debtUSD * BPS * BPS;
        uint256 rhs = target * collateralValueUSD * BPS;

        if (lhs <= rhs) {
            outcome.resultingLtvBps = currentLtvBps;
            return outcome;
        }

        uint256 denominator = (BPS * BPS) - (target * (BPS + bonus));
        if (denominator == 0) revert InvalidRiskParameters();

        uint256 numerator = lhs - rhs;
        uint256 debtToCoverUSD = numerator / denominator;
        if (numerator % denominator != 0) {
            debtToCoverUSD += 1;
        }

        if (debtToCoverUSD > debtUSD) {
            debtToCoverUSD = debtUSD;
        }

        uint256 collateralValueToSeizeUSD = (debtToCoverUSD * (BPS + bonus)) / BPS;
        if (collateralValueToSeizeUSD > collateralValueUSD) {
            collateralValueToSeizeUSD = collateralValueUSD;
        }

        uint256 ethPrice = priceOracle.getETHUSDPrice();
        uint256 collateralToSeizeETH = (collateralValueToSeizeUSD * 1e18) / ethPrice;
        if (collateralToSeizeETH > collateralAmount) {
            collateralToSeizeETH = collateralAmount;
        }

        uint256 remainingDebtUSD = debtUSD > debtToCoverUSD ? debtUSD - debtToCoverUSD : 0;
        uint256 remainingCollateralETH = collateralAmount > collateralToSeizeETH ? collateralAmount - collateralToSeizeETH : 0;

        outcome = LiquidationOutcome({
            debtToCoverUSD: debtToCoverUSD,
            collateralToSeizeETH: collateralToSeizeETH,
            collateralValueSeizedUSD: collateralValueToSeizeUSD,
            resultingLtvBps: calculateLTV(remainingCollateralETH, remainingDebtUSD)
        });
    }

    /// @inheritdoc IRiskEngine
    function getMaxLTVBps() external view returns (uint256) {
        return maxLtvBps;
    }

    /// @inheritdoc IRiskEngine
    function getLiquidationThresholdBps() external view returns (uint256) {
        return liquidationThresholdBps;
    }

    /// @inheritdoc IRiskEngine
    function getTargetLTVBps() external view returns (uint256) {
        return targetLtvBps;
    }

    /// @inheritdoc IRiskEngine
    function getLiquidationBonusBps() external view returns (uint256) {
        return liquidationBonusBps;
    }

    /**
     * @notice Updates the borrow and liquidation risk parameters.
     * @param maxLtvBps_ New maximum healthy LTV in basis points.
     * @param liquidationThresholdBps_ New liquidation threshold in basis points.
     * @param targetLtvBps_ New target LTV in basis points.
     * @param liquidationBonusBps_ New liquidator bonus in basis points.
     */
    function setRiskParameters(
        uint256 maxLtvBps_,
        uint256 liquidationThresholdBps_,
        uint256 targetLtvBps_,
        uint256 liquidationBonusBps_
    ) external onlyRole(RISK_ADMIN_ROLE) {
        _setRiskParameters(maxLtvBps_, liquidationThresholdBps_, targetLtvBps_, liquidationBonusBps_);
    }

    /**
     * @notice Validates and stores the active risk parameter set.
     * @param maxLtvBps_ Proposed maximum healthy LTV.
     * @param liquidationThresholdBps_ Proposed liquidation threshold.
     * @param targetLtvBps_ Proposed target LTV.
     * @param liquidationBonusBps_ Proposed liquidator bonus.
     */
    function _setRiskParameters(
        uint256 maxLtvBps_,
        uint256 liquidationThresholdBps_,
        uint256 targetLtvBps_,
        uint256 liquidationBonusBps_
    ) internal {
        bool invalid = maxLtvBps_ == 0
            || maxLtvBps_ >= liquidationThresholdBps_
            || targetLtvBps_ > liquidationThresholdBps_
            || liquidationThresholdBps_ > BPS
            || targetLtvBps_ > BPS
            || liquidationBonusBps_ > BPS;

        if (invalid) revert InvalidRiskParameters();

        // Ensure the liquidation denominator remains non-zero for all valid parameter combinations.
        uint256 denominator = (BPS * BPS) - (targetLtvBps_ * (BPS + liquidationBonusBps_));
        if (denominator == 0) revert InvalidRiskParameters();

        maxLtvBps = maxLtvBps_;
        liquidationThresholdBps = liquidationThresholdBps_;
        targetLtvBps = targetLtvBps_;
        liquidationBonusBps = liquidationBonusBps_;

        emit RiskParametersUpdated(maxLtvBps_, liquidationThresholdBps_, targetLtvBps_, liquidationBonusBps_);
    }
}
