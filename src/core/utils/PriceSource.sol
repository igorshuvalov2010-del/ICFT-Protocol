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
 * @title PriceSource
 * @notice Enumerates supported ICFT/USD pricing sources.
 * @dev `Manual` is intended for the earliest localhost-only MVP stage.
 * @dev `Chainlink` is reserved for later environments where a trustworthy feed exists.
 *
 * @custom:version 1.0.0
 */
enum PriceSource {
    /// @notice ICFT/USD price is provided manually by an authorized admin.
    Manual,
    /// @notice ICFT/USD price is sourced from a configured Chainlink feed.
    Chainlink
}
