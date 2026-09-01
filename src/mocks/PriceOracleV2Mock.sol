// SPDX-License-Identifier: GPL-3.0-only
pragma solidity ^0.8.20;

import {PriceOracle} from "../core/ICFT/oracle/PriceOracle.sol";

/**
 * @title PriceOracleV2Mock
 * @notice Minimal upgrade target used to verify proxy upgrades during tests.
 * @dev Appends only new logic and does not mutate inherited storage layout.
 */
contract PriceOracleV2Mock is PriceOracle {
    /**
     * @notice Returns a fixed marker so tests can confirm the upgraded implementation is active.
     * @return version Version marker for the upgraded mock implementation.
     */
    function versionMarker() external pure returns (uint256 version) {
        return 2;
    }
}
