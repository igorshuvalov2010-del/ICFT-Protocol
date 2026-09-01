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

import {IPriceOracle} from "./IPriceOracle.sol";
import {IRiskEngine} from "./IRiskEngine.sol";

/**
 * @title ILendingPool
 * @notice Canonical lending-pool interface for collateral, debt, and liquidation state.
 * @dev Borrowing is denominated in ICFT while debt is tracked in internal USD accounting units.
 *
 * @custom:version 1.0.0
 */
interface ILendingPool {
    /**
     * @notice Stores protocol-level support flags for a collateral asset.
     * @param enabled Whether new deposits of the asset are currently accepted.
     * @param isNative Whether the asset represents the native ETH collateral path.
     */
    struct CollateralAsset {
        bool enabled;
        bool isNative;
    }

    /**
     * @notice Stores a user's collateral and debt state.
     * @param collateralETH ETH collateral balance in wei.
     * @param principalDebtUSD Principal debt using internal 1e18 USD precision.
     * @param scaledDebtUSD User debt normalized by the global borrow index.
     * @param lastAccrualIndex Borrow index that was last checkpointed onto the position.
     * @param active Whether the position should be treated as active by integrations and indexing.
     */
    struct Position {
        uint256 collateralETH;
        uint256 principalDebtUSD;
        uint256 scaledDebtUSD;
        uint256 lastAccrualIndex;
        bool active;
    }

    /**
     * @notice Emitted when a user deposits collateral.
     * @param user Borrower whose position was updated.
     * @param asset Collateral asset address, or zero address for native ETH.
     * @param amount Asset amount added using the asset's own decimals.
     * @param totalCollateral User's resulting collateral balance for the asset.
     */
    event DepositCollateral(address indexed user, address indexed asset, uint256 amount, uint256 totalCollateral);

    /**
     * @notice Emitted when a user withdraws collateral.
     * @param user Borrower whose position was updated.
     * @param asset Collateral asset address, or zero address for native ETH.
     * @param amount Asset amount withdrawn using the asset's own decimals.
     * @param remainingCollateral User's remaining collateral balance for the asset.
     */
    event WithdrawCollateral(address indexed user, address indexed asset, uint256 amount, uint256 remainingCollateral);

    /**
     * @notice Emitted when a collateral asset support flag changes.
     * @param asset Collateral asset address, or zero address for native ETH.
     * @param enabled Whether new deposits of the asset are currently accepted.
     * @param isNative Whether the asset represents native ETH.
     */
    event CollateralAssetUpdated(address indexed asset, bool enabled, bool isNative);

    /**
     * @notice Emitted when a user borrows ICFT.
     * @param user Borrower whose debt was increased.
     * @param amountICFT ICFT amount transferred to the borrower.
     * @param addedDebtUSD Principal debt added in internal USD units.
     * @param totalDebtUSD Borrower's resulting total debt in internal USD units.
     */
    event Borrow(address indexed user, uint256 amountICFT, uint256 addedDebtUSD, uint256 totalDebtUSD);

    /**
     * @notice Emitted when a user repays debt with ICFT.
     * @param user Borrower whose debt was reduced.
     * @param amountICFT ICFT amount taken from the borrower.
     * @param repaidDebtUSD Debt value extinguished in internal USD units.
     * @param remainingDebtUSD Borrower's remaining total debt in internal USD units.
     */
    event Repay(address indexed user, uint256 amountICFT, uint256 repaidDebtUSD, uint256 remainingDebtUSD);

    /**
     * @notice Emitted when a position is liquidated.
     * @param user Borrower whose position was liquidated.
     * @param liquidator Authorized liquidation caller that repaid ICFT.
     * @param repaidICFT ICFT amount consumed during liquidation.
     * @param repaidDebtUSD Debt value extinguished in internal USD units.
     * @param collateralAsset Collateral asset seized from the borrower.
     * @param collateralSeizedAmount Collateral amount seized using the asset's own decimals.
     * @param collateralValueSeizedUSD USD value represented by the seized collateral.
     * @param resultingLtvBps Borrower's resulting LTV after liquidation, in basis points.
     */
    event Liquidation(
        address indexed user,
        address indexed liquidator,
        address indexed collateralAsset,
        uint256 repaidICFT,
        uint256 repaidDebtUSD,
        uint256 collateralSeizedAmount,
        uint256 collateralValueSeizedUSD,
        uint256 resultingLtvBps
    );

    /**
     * @notice Deposits native ETH as collateral for the caller.
     */
    function depositCollateral() external payable;

    /**
     * @notice Deposits ERC20 collateral for the caller.
     * @param asset Collateral token address.
     * @param amount Token amount using the token's own decimals.
     */
    function depositCollateral(address asset, uint256 amount) external;

    /**
     * @notice Withdraws native ETH collateral.
     * @param amountETH ETH amount to withdraw in wei.
     */
    function withdrawCollateral(uint256 amountETH) external;

    /**
     * @notice Withdraws ERC20 collateral.
     * @param asset Collateral token address.
     * @param amount Token amount using the token's own decimals.
     */
    function withdrawCollateral(address asset, uint256 amount) external;

    /**
     * @notice Emitted when interest is accrued onto a position.
     * @param user Borrower whose debt was updated.
     * @param interestUSD Newly accrued interest in internal USD units.
     * @param totalAccruedInterestUSD Position-level accrued interest after the update.
     */
    event InterestAccrued(address indexed user, uint256 interestUSD, uint256 totalAccruedInterestUSD);

    /**
     * @notice Emitted when the global borrow index is accrued forward in time.
     * @param aprBps APR bucket used during the accrual window, in basis points.
     * @param previousBorrowIndex Borrow index before accrual.
     * @param newBorrowIndex Borrow index after accrual.
     * @param totalDebtUSD Aggregate debt after accrual in internal USD units.
     * @param totalAccruedInterestUSD Aggregate unpaid interest after accrual in internal USD units.
     */
    event GlobalInterestAccrued(
        uint256 aprBps,
        uint256 previousBorrowIndex,
        uint256 newBorrowIndex,
        uint256 totalDebtUSD,
        uint256 totalAccruedInterestUSD
    );

    /**
     * @notice Emitted when a mutable pool parameter is updated.
     * @param parameter Identifier for the updated parameter.
     * @param value New parameter value.
     */
    event ParameterUpdated(bytes32 indexed parameter, uint256 value);

    /**
     * @notice Emitted when aggregate Fund A accounting values change.
     * @param fundALiquidityICFT ICFT principal still assigned to Fund A liquidity.
     * @param totalBorrowedICFT Total ICFT currently borrowed by users.
     * @param totalPrincipalDebtUSD Aggregate protocol principal debt in internal USD units.
     * @param totalAccruedInterestUSD Aggregate unpaid interest in internal USD units.
     * @param protocolRevenueICFT ICFT revenue attributable to interest spread.
     */
    event FundAAccountingUpdated(
        uint256 fundALiquidityICFT,
        uint256 totalBorrowedICFT,
        uint256 totalPrincipalDebtUSD,
        uint256 totalAccruedInterestUSD,
        uint256 protocolRevenueICFT
    );

    /**
     * @notice Repays a liquidatable position and transfers seized collateral to the recipient.
     * @param user Borrower being liquidated.
     * @param collateralAsset Collateral asset selected for seizure, or zero address for native ETH.
     * @param maxICFTToRepay Maximum ICFT the caller is willing to repay.
     * @param collateralRecipient Address that should receive seized collateral.
     */
    function liquidate(address user, address collateralAsset, uint256 maxICFTToRepay, address collateralRecipient)
        external;

    /**
     * @notice Returns a user's total debt in internal USD accounting units.
     * @param user Borrower address.
     * @return debtUSD Total debt including accrued interest, using 1e18 precision.
     */
    function getDebt(address user) external view returns (uint256);

    /**
     * @notice Returns the raw stored user position.
     * @param user Borrower address.
     * @return position Stored position snapshot.
     */
    function getPosition(address user) external view returns (Position memory);

    /**
     * @notice Returns a user's collateral balance for a specific asset.
     * @param user Borrower address.
     * @param asset Collateral asset address, or zero address for native ETH.
     * @return balance Asset balance using the asset's own decimals.
     */
    function getCollateralBalance(address user, address asset) external view returns (uint256 balance);

    /**
     * @notice Returns the list of collateral assets known to the pool.
     * @return assets Registered collateral asset addresses, including zero address for native ETH.
     */
    function getSupportedCollateralAssets() external view returns (address[] memory assets);

    /**
     * @notice Returns the pool support flags for a collateral asset.
     * @param asset Collateral asset address, or zero address for native ETH.
     * @return collateralAsset Pool-level asset configuration.
     */
    function getCollateralAsset(address asset) external view returns (CollateralAsset memory collateralAsset);

    /**
     * @notice Returns the USD accounting value of a user's full collateral basket.
     * @param user Borrower address.
     * @return collateralValueUSD Aggregate collateral value using 1e18 precision.
     */
    function getCollateralValueUSD(address user) external view returns (uint256 collateralValueUSD);

    /**
     * @notice Returns whether the user is liquidatable at current prices.
     * @param user Borrower address.
     * @return liquidatable True when the position is eligible for liquidation.
     */
    function isLiquidatable(address user) external view returns (bool);

    /**
     * @notice Returns the risk engine used by the pool.
     * @return engine Risk engine contract reference.
     */
    function riskEngine() external view returns (IRiskEngine);

    /**
     * @notice Returns the price oracle used by the pool.
     * @return oracle Price oracle contract reference.
     */
    function priceOracle() external view returns (IPriceOracle);
}
