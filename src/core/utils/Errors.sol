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

/// @notice Thrown when a zero address or otherwise invalid address is provided.
error InvalidAddress();

/// @notice Thrown when a token recipient is invalid.
error InvalidRecipient();

/// @notice Thrown when an input amount is invalid.
error InvalidAmount();

/// @notice Thrown when a zero amount is provided where a positive amount is required.
error ZeroAmount();

/// @notice Thrown when fixed token allocations do not add up to the expected total supply.
error InvalidTokenAllocation();

/// @notice Thrown when an oracle address is missing or invalid.
error InvalidOracleAddress();

/// @notice Thrown when an oracle answer is zero, negative, or otherwise unusable.
error InvalidOracleAnswer();

/// @notice Thrown when the oracle price is older than the configured freshness window.
error StaleOraclePrice();

/// @notice Thrown when a price feed uses unsupported decimals.
error UnsupportedPriceDecimals();

/// @notice Thrown when the manual ICFT price configuration is invalid.
error InvalidManualPrice();

/// @notice Thrown when collateral asset decimals are unsupported by protocol math.
error InvalidAssetDecimals();

/// @notice Thrown when risk parameters are inconsistent or unsafe.
error InvalidRiskParameters();

/// @notice Thrown when interest rate model parameters are invalid.
error InvalidRateConfig();

/// @notice Thrown when a user attempts to withdraw more collateral than available.
error InsufficientCollateral();

/// @notice Thrown when the requested collateral asset is not registered or oracle-backed.
error UnsupportedCollateralAsset();

/// @notice Thrown when a borrow or withdrawal would exceed the allowed LTV.
error BorrowExceedsLTV();

/// @notice Thrown when the pool does not have enough available ICFT liquidity.
error InsufficientLiquidity();

/// @notice Thrown when borrowing would push utilization above the configured cap.
error BorrowingDisabledAtUtilization();

/// @notice Thrown when an operation requires outstanding debt but none exists.
error NoDebt();

/// @notice Thrown when a repayment rounds down to zero effective debt reduction.
error NothingToRepay();

/// @notice Thrown when a position is not eligible for liquidation.
error NotLiquidatable();

/// @notice Thrown when the liquidation repayment requirement exceeds the caller limit.
error SlippageExceeded();

/// @notice Thrown when direct ETH transfers to the pool are not allowed.
error DirectETHTransfersDisabled();

/// @notice Thrown when an ETH transfer fails.
error EthTransferFailed();

/// @notice Thrown when the liquidation engine needs more ICFT than the operator allows.
error MaxRepayBelowRequired();
