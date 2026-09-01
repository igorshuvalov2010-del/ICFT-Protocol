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

import {PriceSource} from "../utils/PriceSource.sol";

/**
 * @title IPriceOracle
 * @notice Canonical price-oracle interface for the ICFT protocol.
 * @dev All returned USD values are normalized to 1e18 precision and represent an internal accounting unit.
 * @dev The interface abstracts both Chainlink-backed and manually managed ICFT pricing for the MVP phase.
 *
 * @custom:version 1.0.0
 */
interface IPriceOracle {
    /**
     * @notice Emitted when the native ETH/USD feed is updated.
     * @param feed Address of the new native feed contract.
     */
    event NativeUSDFeedUpdated(address indexed feed);

    /**
     * @notice Emitted when the manual ICFT/USD price is updated.
     * @param rawPrice Raw price value before normalization.
     * @param decimals Decimals used by the raw price input.
     * @param normalizedPrice Price normalized to 1e18 precision.
     */
    event ICFTPriceUpdated(uint256 rawPrice, uint8 decimals, uint256 normalizedPrice);

    /**
     * @notice Emitted when the active ICFT pricing source is changed.
     * @param source Newly selected pricing source.
     */
    event OracleSourceUpdated(PriceSource indexed source);

    /**
     * @notice Emitted when the optional Chainlink ICFT/USD feed is updated.
     * @param feed Address of the new feed contract.
     */
    event ICFTUSDFeedUpdated(address indexed feed);

    /**
     * @notice Emitted when an ERC20 collateral feed configuration is updated.
     * @param asset Collateral token address.
     * @param feed Chainlink feed address for the asset/USD pair.
     * @param assetDecimals Asset token decimals used by conversion math.
     * @param enabled Whether the asset is considered supported by the oracle.
     */
    event CollateralAssetFeedUpdated(address indexed asset, address indexed feed, uint8 assetDecimals, bool enabled);

    /**
     * @notice Emitted when the maximum accepted oracle staleness window is updated.
     * @param newMaxPriceAge New freshness threshold in seconds.
     */
    event MaxPriceAgeUpdated(uint256 newMaxPriceAge);

    /**
     * @notice Returns the ETH/USD price normalized to 1e18 precision.
     * @return price ETH/USD price in the protocol's internal 1e18 USD format.
     */
    function getETHUSDPrice() external view returns (uint256);

    /**
     * @notice Returns an arbitrary collateral asset/USD price normalized to 1e18 precision.
     * @param asset Collateral asset address, or zero address for native ETH.
     * @return price Asset/USD price in the protocol's internal 1e18 USD format.
     */
    function getAssetUSDPrice(address asset) external view returns (uint256);

    /**
     * @notice Returns the decimals used by a supported collateral asset.
     * @param asset Collateral asset address, or zero address for native ETH.
     * @return decimals Asset decimals used by conversion math.
     */
    function getAssetDecimals(address asset) external view returns (uint8 decimals);

    /**
     * @notice Returns whether the oracle supports price conversions for the collateral asset.
     * @param asset Collateral asset address, or zero address for native ETH.
     * @return supported True when the asset has an active oracle configuration.
     */
    function isCollateralAssetSupported(address asset) external view returns (bool supported);

    /**
     * @notice Returns the ICFT/USD price normalized to 1e18 precision.
     * @return price ICFT/USD price in the protocol's internal 1e18 USD format.
     */
    function getICFTUSDPrice() external view returns (uint256);

    /**
     * @notice Returns the currently active ICFT price source.
     * @return source Enum value describing whether ICFT pricing is manual or Chainlink-based.
     */
    function getICFTPriceSource() external view returns (PriceSource);

    /**
     * @notice Normalizes an arbitrary price into 1e18 precision.
     * @param price Raw input price.
     * @param priceDecimals Decimals used by the raw price.
     * @return normalizedPrice Price rescaled into 1e18 precision.
     */
    function normalizePrice(uint256 price, uint8 priceDecimals) external pure returns (uint256);

    /**
     * @notice Converts an ICFT token amount into the protocol USD accounting unit.
     * @param icftAmount Amount of ICFT tokens using 18 token decimals.
     * @return usdAmount Equivalent protocol USD value using 1e18 precision.
     */
    function convertICFTToUSD(uint256 icftAmount) external view returns (uint256);

    /**
     * @notice Converts a protocol USD accounting amount into ICFT.
     * @param usdAmount USD accounting amount using 1e18 precision.
     * @param roundUp Whether the conversion should round up to avoid underpayment.
     * @return icftAmount Equivalent ICFT token amount using 18 token decimals.
     */
    function convertUSDToICFT(uint256 usdAmount, bool roundUp) external view returns (uint256);

    /**
     * @notice Converts a collateral-asset amount into the protocol USD accounting unit.
     * @param asset Collateral asset address, or zero address for native ETH.
     * @param assetAmount Asset amount using the asset's own token decimals.
     * @return usdAmount Equivalent protocol USD value using 1e18 precision.
     */
    function convertAssetToUSD(address asset, uint256 assetAmount) external view returns (uint256 usdAmount);

    /**
     * @notice Converts a protocol USD accounting amount into collateral-asset units.
     * @param asset Collateral asset address, or zero address for native ETH.
     * @param usdAmount USD accounting amount using 1e18 precision.
     * @param roundUp Whether the conversion should round up to avoid under-seizing.
     * @return assetAmount Equivalent asset amount using the asset's own decimals.
     */
    function convertUSDToAsset(address asset, uint256 usdAmount, bool roundUp) external view returns (uint256 assetAmount);
}
