// SPDX-License-Identifier: GPL-3.0-only
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
