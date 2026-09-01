// SPDX-License-Identifier: GPL-3.0-only
/**
 * NOTICE
 *
 * ICFT is an upgradeable lending and programmable credit protocol developed
 * to let users borrow ICFT against on-chain collateral through transparent,
 * modular, and upgradeable smart contracts on EVM-compatible blockchains.
 *
 * Copyright (C) 2026, ICFT contributors.
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program. If not, see <https://www.gnu.org/licenses/>.
 */
pragma solidity ^0.8.20;

/**
 * @title ILiquidationEngine
 * @notice Canonical helper interface for restricted ICFT liquidations.
 * @dev Implementations repay ICFT debt through the pool and forward seized collateral to an operator-selected beneficiary.
 *
 * @custom:version 1.0.0
 */
interface ILiquidationEngine {
    /**
     * @notice Aggregated preview of a liquidation opportunity.
     * @param isLiquidatable Whether the target user is currently liquidatable.
     * @param collateralAsset Collateral asset selected for seizure, or zero address for native ETH.
     * @param debtUsd User's total debt in internal USD units.
     * @param requiredIcft ICFT needed to execute the current liquidation slice.
     * @param collateralToSeizeAmount Asset amount expected to be seized using the asset's own decimals.
     * @param collateralValueSeizedUsd USD value represented by the seized collateral.
     * @param resultingLtvBps Projected user LTV after liquidation in basis points.
     */
    struct LiquidationPreview {
        bool isLiquidatable;
        address collateralAsset;
        uint256 debtUsd;
        uint256 requiredIcft;
        uint256 collateralToSeizeAmount;
        uint256 collateralValueSeizedUsd;
        uint256 resultingLtvBps;
    }

    /**
     * @notice Emitted when a liquidation is executed through the helper.
     * @param user Borrower whose position was liquidated.
     * @param operator Authorized operator that initiated the liquidation.
     * @param collateralAsset Collateral asset seized from the borrower.
     * @param collateralBeneficiary Address that received the seized collateral.
     * @param repaidIcft ICFT actually consumed by the liquidation.
     * @param repaidUsd Debt value extinguished in internal USD units.
     * @param seizedCollateralAmount Collateral amount seized using the asset's own decimals.
     * @param resultingLtvBps Borrower's resulting LTV after liquidation, in basis points.
     */
    event LiquidationExecuted(
        address indexed user,
        address indexed operator,
        address indexed collateralAsset,
        address collateralBeneficiary,
        uint256 repaidIcft,
        uint256 repaidUsd,
        uint256 seizedCollateralAmount,
        uint256 resultingLtvBps
    );

    /**
     * @notice Emitted when admin rescues ETH that was sent to the helper by mistake.
     * @param recipient Address that received the rescued ETH.
     * @param amount Amount of native ETH transferred out.
     */
    event NativeRecovered(address indexed recipient, uint256 amount);

    /**
     * @notice Returns a liquidation preview for a borrower.
     * @param user Borrower address to inspect.
     * @param collateralAsset Collateral asset selected for seizure, or zero address for native ETH.
     * @return preview Aggregated liquidation preview.
     */
    function previewLiquidation(address user, address collateralAsset)
        external
        view
        returns (LiquidationPreview memory preview);

    /**
     * @notice Executes a liquidation on behalf of an authorized operator.
     * @param user Borrower to liquidate.
     * @param collateralAsset Collateral asset selected for seizure, or zero address for native ETH.
     * @param maxIcftToRepay Maximum ICFT the operator is willing to commit.
     * @param collateralBeneficiary Recipient of seized collateral.
     * @return repaidIcft ICFT actually consumed.
     * @return repaidUsd Debt value extinguished in internal USD units.
     * @return seizedCollateralAmount Collateral amount seized using the asset's own decimals.
     */
    function executeLiquidation(
        address user,
        address collateralAsset,
        uint256 maxIcftToRepay,
        address payable collateralBeneficiary
    )
        external
        returns (uint256 repaidIcft, uint256 repaidUsd, uint256 seizedCollateralAmount);

    /**
     * @notice Recovers native ETH accidentally sent to the liquidation helper.
     * @param recipient Address that should receive the rescued ETH.
     * @param amount Native ETH amount to withdraw.
     */
    function recoverNative(address payable recipient, uint256 amount) external;
}
