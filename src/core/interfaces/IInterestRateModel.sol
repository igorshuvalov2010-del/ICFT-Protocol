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
 * @title IInterestRateModel
 * @notice Canonical interface for utilization-based borrow APR logic.
 * @dev Rates are expressed in basis points and selected from a piecewise utilization curve.
 *
 * @custom:version 1.0.0
 */
interface IInterestRateModel {
    /**
     * @notice Describes the utilization curve used to price borrows.
     * @param kink1Bps First utilization threshold in basis points.
     * @param kink2Bps Second utilization threshold in basis points.
     * @param kink3Bps Third utilization threshold in basis points.
     * @param rate1Bps Borrow APR below kink1, in basis points.
     * @param rate2Bps Borrow APR from kink1 up to kink2, in basis points.
     * @param rate3Bps Borrow APR from kink2 up to kink3, in basis points.
     * @param rate4Bps Borrow APR at or above kink3, in basis points.
     * @param maxBorrowUtilizationBps Hard utilization cap for opening new borrows, in basis points.
     */
    struct RateConfig {
        uint256 kink1Bps;
        uint256 kink2Bps;
        uint256 kink3Bps;
        uint256 rate1Bps;
        uint256 rate2Bps;
        uint256 rate3Bps;
        uint256 rate4Bps;
        uint256 maxBorrowUtilizationBps;
    }

    /**
     * @notice Emitted when the borrow curve configuration is updated.
     * @param config Complete new rate configuration.
     */
    event RateConfigUpdated(RateConfig config);

    /**
     * @notice Returns the borrow APR in basis points for a given utilization.
     * @param utilizationBps Current utilization in basis points.
     * @return aprBps Borrow APR in basis points.
     */
    function getBorrowRateBps(uint256 utilizationBps) external view returns (uint256);

    /**
     * @notice Returns the utilization level above which new borrows are blocked.
     * @return maxBorrowUtilizationBps Utilization cap in basis points.
     */
    function getMaxBorrowUtilizationBps() external view returns (uint256);
}
