// SPDX-License-Identifier: GPL-3.0-only
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
}
