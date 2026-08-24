// SPDX-License-Identifier: GPL-3.0-only
pragma solidity ^0.8.20;

import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";

import {IInterestRateModel} from "../../interfaces/IInterestRateModel.sol";
import {InvalidAddress, InvalidRateConfig} from "../../utils/Errors.sol";

/**
 * @title InterestRateModel
 * @notice Defines the utilization-based borrow APR curve for ICFT loans.
 * @dev The model uses a four-bucket piecewise curve selected by utilization thresholds.
 * @dev Rates are expressed in basis points and are intended to be consumed by the lending pool during accrual.
 *
 * @custom:version 1.0.0
 */
contract InterestRateModel is IInterestRateModel, AccessControl {
    /// @notice Role allowed to update the utilization curve configuration.
    bytes32 public constant RATE_ADMIN_ROLE = keccak256("RATE_ADMIN_ROLE");

    /// @notice Basis-point denominator used for utilization and APR values.
    uint256 public constant BPS = 10_000;

    /// @notice Active utilization curve configuration.
    RateConfig public rateConfig;

    /**
     * @notice Creates the rate model with the initial piecewise utilization curve.
     * @param admin Address that receives admin and rate-admin roles.
     * @param initialConfig Initial borrow-curve configuration.
     */
    constructor(address admin, RateConfig memory initialConfig) {
        if (admin == address(0)) revert InvalidAddress();

        _grantRole(DEFAULT_ADMIN_ROLE, admin);
        _grantRole(RATE_ADMIN_ROLE, admin);
        _setRateConfig(initialConfig);
    }

    /// @inheritdoc IInterestRateModel
    function getBorrowRateBps(uint256 utilizationBps) external view returns (uint256) {
        RateConfig memory config = rateConfig;

        if (utilizationBps < config.kink1Bps) return config.rate1Bps;
        if (utilizationBps < config.kink2Bps) return config.rate2Bps;
        if (utilizationBps < config.kink3Bps) return config.rate3Bps;
        return config.rate4Bps;
    }

    /// @inheritdoc IInterestRateModel
    function getMaxBorrowUtilizationBps() external view returns (uint256) {
        return rateConfig.maxBorrowUtilizationBps;
    }

    /**
     * @notice Updates the borrow curve configuration.
     * @param newConfig Complete replacement rate configuration.
     */
    function setRateConfig(RateConfig memory newConfig) external onlyRole(RATE_ADMIN_ROLE) {
        _setRateConfig(newConfig);
    }

    /**
     * @notice Validates and stores a new utilization curve.
     * @param newConfig Proposed rate configuration.
     */
    function _setRateConfig(RateConfig memory newConfig) internal {
        bool validOrder = newConfig.kink1Bps < newConfig.kink2Bps
            && newConfig.kink2Bps < newConfig.kink3Bps
            && newConfig.kink3Bps <= BPS
            && newConfig.maxBorrowUtilizationBps <= BPS;

        bool validRates = newConfig.rate1Bps <= newConfig.rate2Bps
            && newConfig.rate2Bps <= newConfig.rate3Bps
            && newConfig.rate3Bps <= newConfig.rate4Bps;

        if (!validOrder || !validRates || newConfig.maxBorrowUtilizationBps < newConfig.kink3Bps) {
            revert InvalidRateConfig();
        }

        // Replace the entire rate curve atomically so accrual always sees a coherent configuration.
        rateConfig = newConfig;
        emit RateConfigUpdated(newConfig);
    }
}
