// SPDX-License-Identifier: GPL-3.0-only
pragma solidity ^0.8.20;

/**
 * @title ILiquidationEngine
 * @notice Canonical helper interface for restricted ICFT liquidations.
 * @dev Implementations repay ICFT debt through the pool and forward seized ETH to an operator-selected beneficiary.
 *
 * @custom:version 1.0.0
 */
interface ILiquidationEngine {
    /**
     * @notice Aggregated preview of a liquidation opportunity.
     * @param isLiquidatable Whether the target user is currently liquidatable.
     * @param debtUsd User's total debt in internal USD units.
     * @param requiredIcft ICFT needed to execute the current liquidation slice.
     * @param collateralToSeizeEth ETH expected to be seized in wei.
     * @param collateralValueSeizedUsd USD value represented by the seized collateral.
     * @param resultingLtvBps Projected user LTV after liquidation in basis points.
     */
    struct LiquidationPreview {
        bool isLiquidatable;
        uint256 debtUsd;
        uint256 requiredIcft;
        uint256 collateralToSeizeEth;
        uint256 collateralValueSeizedUsd;
        uint256 resultingLtvBps;
    }

    /**
     * @notice Emitted when a liquidation is executed through the helper.
     * @param user Borrower whose position was liquidated.
     * @param operator Authorized operator that initiated the liquidation.
     * @param collateralBeneficiary Address that received the seized ETH.
     * @param repaidIcft ICFT actually consumed by the liquidation.
     * @param repaidUsd Debt value extinguished in internal USD units.
     * @param seizedEth ETH collateral seized in wei.
     * @param resultingLtvBps Borrower's resulting LTV after liquidation, in basis points.
     */
    event LiquidationExecuted(
        address indexed user,
        address indexed operator,
        address indexed collateralBeneficiary,
        uint256 repaidIcft,
        uint256 repaidUsd,
        uint256 seizedEth,
        uint256 resultingLtvBps
    );

    /**
     * @notice Returns a liquidation preview for a borrower.
     * @param user Borrower address to inspect.
     * @return preview Aggregated liquidation preview.
     */
    function previewLiquidation(address user) external view returns (LiquidationPreview memory preview);

    /**
     * @notice Executes a liquidation on behalf of an authorized operator.
     * @param user Borrower to liquidate.
     * @param maxIcftToRepay Maximum ICFT the operator is willing to commit.
     * @param collateralBeneficiary Recipient of seized ETH collateral.
     * @return repaidIcft ICFT actually consumed.
     * @return repaidUsd Debt value extinguished in internal USD units.
     * @return seizedEth ETH collateral seized in wei.
     */
    function executeLiquidation(address user, uint256 maxIcftToRepay, address payable collateralBeneficiary)
        external
        returns (uint256 repaidIcft, uint256 repaidUsd, uint256 seizedEth);
}
