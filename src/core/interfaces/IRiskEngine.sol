// SPDX-License-Identifier: GPL-3.0-only
pragma solidity ^0.8.20;

/**
 * @title IRiskEngine
 * @notice Canonical collateral-risk and liquidation interface for the ICFT protocol.
 * @dev All USD amounts are accounting-only values normalized to 1e18 precision.
 * @dev Implementations are responsible for LTV checks, liquidation eligibility, and target-LTV liquidation sizing.
 *
 * @custom:version 1.0.0
 */
interface IRiskEngine {
    /**
     * @notice Describes the liquidation slice required for a position.
     * @param debtToCoverUSD Amount of debt that should be repaid in internal USD units.
     * @param collateralToSeizeETH Amount of ETH collateral to seize from the borrower.
     * @param collateralValueSeizedUSD USD value represented by the seized collateral.
     * @param resultingLtvBps Borrower's projected resulting LTV after liquidation, in basis points.
     */
    struct LiquidationOutcome {
        uint256 debtToCoverUSD;
        uint256 collateralToSeizeETH;
        uint256 collateralValueSeizedUSD;
        uint256 resultingLtvBps;
    }

    /**
     * @notice Emitted when risk parameters are updated.
     * @param maxLtvBps Maximum allowed borrow LTV in basis points.
     * @param liquidationThresholdBps LTV threshold at or above which a position becomes liquidatable.
     * @param targetLtvBps Target LTV the liquidation math aims to restore.
     * @param liquidationBonusBps Liquidator bonus applied to seized collateral value, in basis points.
     */
    event RiskParametersUpdated(
        uint256 maxLtvBps,
        uint256 liquidationThresholdBps,
        uint256 targetLtvBps,
        uint256 liquidationBonusBps
    );

    /**
     * @notice Returns the USD accounting value of ETH collateral using 1e18 precision.
     * @param collateralAmount ETH collateral amount in wei.
     * @return collateralValueUSD USD accounting value using 1e18 precision.
     */
    function getCollateralValueUSD(uint256 collateralAmount) external view returns (uint256);

    /**
     * @notice Returns the maximum borrow capacity in protocol USD units.
     * @param collateralAmount ETH collateral amount in wei.
     * @return maxBorrowUSD Maximum debt capacity using internal USD precision.
     */
    function getMaxBorrowUSD(uint256 collateralAmount) external view returns (uint256);

    /**
     * @notice Returns the loan-to-value ratio in basis points.
     * @param collateralAmount ETH collateral amount in wei.
     * @param debtUSD Total debt using internal USD precision.
     * @return ltvBps Loan-to-value ratio expressed in basis points.
     */
    function calculateLTV(uint256 collateralAmount, uint256 debtUSD) external view returns (uint256);

    /**
     * @notice Returns whether a position is currently liquidatable.
     * @param collateralAmount ETH collateral amount in wei.
     * @param debtUSD Total debt using internal USD precision.
     * @return liquidatable True when the position is at or above the liquidation threshold.
     */
    function isLiquidatable(uint256 collateralAmount, uint256 debtUSD) external view returns (bool);

    /**
     * @notice Computes the liquidation slice required to move a position toward target LTV.
     * @param collateralAmount ETH collateral amount in wei.
     * @param debtUSD Total debt using internal USD precision.
     * @return outcome Calculated liquidation slice for the position.
     */
    function calculateLiquidation(uint256 collateralAmount, uint256 debtUSD) external view returns (LiquidationOutcome memory);

    /**
     * @notice Returns the maximum allowed healthy LTV.
     * @return maxLtvBps Maximum allowed LTV in basis points.
     */
    function getMaxLTVBps() external view returns (uint256);

    /**
     * @notice Returns the liquidation threshold.
     * @return thresholdBps LTV threshold in basis points.
     */
    function getLiquidationThresholdBps() external view returns (uint256);

    /**
     * @notice Returns the target LTV used during liquidation math.
     * @return targetLtvBps Target LTV in basis points.
     */
    function getTargetLTVBps() external view returns (uint256);

    /**
     * @notice Returns the liquidator bonus applied to seized collateral.
     * @return bonusBps Bonus in basis points.
     */
    function getLiquidationBonusBps() external view returns (uint256);
}
