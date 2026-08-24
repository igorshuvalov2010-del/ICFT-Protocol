// SPDX-License-Identifier: GPL-3.0-only
pragma solidity ^0.8.20;

import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";
import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

import {IPriceOracle} from "../../interfaces/IPriceOracle.sol";
import {
    InvalidManualPrice,
    InvalidOracleAddress,
    InvalidOracleAnswer,
    StaleOraclePrice,
    UnsupportedPriceDecimals
} from "../../utils/Errors.sol";
import {PriceSource} from "../../utils/PriceSource.sol";

/**
 * @title PriceOracle
 * @notice Provides ETH/USD and ICFT/USD prices normalized to 1e18 precision.
 * @dev The protocol uses USD as an internal accounting unit, not as a stablecoin token balance.
 * @dev ETH/USD is sourced from Chainlink while ICFT/USD can be sourced from manual admin updates or Chainlink.
 * @dev Manual ICFT pricing exists for MVP deployments where no trustworthy onchain market feed is available yet.
 *
 * @custom:version 1.0.0
 */
contract PriceOracle is IPriceOracle, AccessControl {
    /// @notice Role allowed to manage oracle configuration and manual price updates.
    bytes32 public constant ORACLE_ADMIN_ROLE = keccak256("ORACLE_ADMIN_ROLE");

    /// @notice Internal precision used for normalized USD accounting.
    uint256 public constant INTERNAL_PRICE_PRECISION = 1e18;

    /// @notice Chainlink ETH/USD feed used for collateral valuation.
    AggregatorV3Interface public immutable ethUsdFeed;
    /// @notice Optional Chainlink ICFT/USD feed used when ICFT pricing source is set to Chainlink.
    AggregatorV3Interface public icftUsdFeed;

    /// @notice Active pricing source used for ICFT/USD conversions.
    PriceSource public icftPriceSource = PriceSource.Manual;

    /// @notice Raw manually configured ICFT/USD price before normalization.
    uint256 public manualICFTPrice;
    /// @notice Decimals used by the manual ICFT/USD price input.
    uint8 public manualICFTPriceDecimals;
    /// @notice Maximum accepted age for Chainlink prices, in seconds.
    uint256 public maxPriceAge;

    /**
     * @notice Creates the oracle with a Chainlink ETH/USD feed and an initial manual ICFT/USD price.
     * @param admin Address that receives admin and oracle-admin roles.
     * @param ethUsdFeed_ Chainlink ETH/USD feed address.
     * @param maxPriceAge_ Maximum accepted staleness for Chainlink prices, in seconds.
     * @param initialManualICFTPrice Initial raw manual ICFT/USD price.
     * @param initialManualICFTPriceDecimals Decimals used by the initial manual price.
     */
    constructor(
        address admin,
        address ethUsdFeed_,
        uint256 maxPriceAge_,
        uint256 initialManualICFTPrice,
        uint8 initialManualICFTPriceDecimals
    ) {
        if (admin == address(0) || ethUsdFeed_ == address(0)) revert InvalidOracleAddress();
        if (maxPriceAge_ == 0) revert InvalidManualPrice();

        _grantRole(DEFAULT_ADMIN_ROLE, admin);
        _grantRole(ORACLE_ADMIN_ROLE, admin);

        // Persist immutable and mutable oracle configuration before enabling price reads.
        ethUsdFeed = AggregatorV3Interface(ethUsdFeed_);
        maxPriceAge = maxPriceAge_;

        // Seed the manual ICFT/USD price so downstream conversions are available immediately.
        _setManualICFTPrice(initialManualICFTPrice, initialManualICFTPriceDecimals);
    }

    /// @inheritdoc IPriceOracle
    function getETHUSDPrice() external view returns (uint256) {
        return _getChainlinkPrice(ethUsdFeed);
    }

    /// @inheritdoc IPriceOracle
    function getICFTUSDPrice() external view returns (uint256) {
        if (icftPriceSource == PriceSource.Manual) {
            return normalizePrice(manualICFTPrice, manualICFTPriceDecimals);
        }

        return _getChainlinkPrice(icftUsdFeed);
    }

    /// @inheritdoc IPriceOracle
    function getICFTPriceSource() external view returns (PriceSource) {
        return icftPriceSource;
    }

    /// @inheritdoc IPriceOracle
    function normalizePrice(uint256 price, uint8 priceDecimals) public pure returns (uint256) {
        if (price == 0) revert InvalidOracleAnswer();
        if (priceDecimals > 18) revert UnsupportedPriceDecimals();

        if (priceDecimals == 18) {
            return price;
        }

        return price * (10 ** (18 - priceDecimals));
    }

    /// @inheritdoc IPriceOracle
    function convertICFTToUSD(uint256 icftAmount) external view returns (uint256) {
        return _convertTokenToUSD(icftAmount, this.getICFTUSDPrice());
    }

    /// @inheritdoc IPriceOracle
    function convertUSDToICFT(uint256 usdAmount, bool roundUp) external view returns (uint256) {
        return _convertUSDToToken(usdAmount, this.getICFTUSDPrice(), roundUp);
    }

    /**
     * @notice Updates the manual ICFT/USD price used in MVP mode.
     * @param price Raw manual ICFT/USD price.
     * @param decimals_ Decimals used by the raw manual price.
     */
    function setManualICFTPrice(uint256 price, uint8 decimals_) external onlyRole(ORACLE_ADMIN_ROLE) {
        _setManualICFTPrice(price, decimals_);
    }

    /**
     * @notice Configures the optional Chainlink ICFT/USD feed address.
     * @param feed Address of the Chainlink ICFT/USD feed.
     */
    function setICFTUSDFeed(address feed) external onlyRole(ORACLE_ADMIN_ROLE) {
        if (feed == address(0)) revert InvalidOracleAddress();
        icftUsdFeed = AggregatorV3Interface(feed);
        emit ICFTUSDFeedUpdated(feed);
    }

    /**
     * @notice Switches the active ICFT pricing source between Manual and Chainlink.
     * @param source New price source enum value.
     */
    function setICFTPriceSource(PriceSource source) external onlyRole(ORACLE_ADMIN_ROLE) {
        if (source == PriceSource.Chainlink && address(icftUsdFeed) == address(0)) {
            revert InvalidOracleAddress();
        }

        icftPriceSource = source;
        emit OracleSourceUpdated(source);
    }

    /**
     * @notice Updates the maximum accepted age for Chainlink prices.
     * @param newMaxPriceAge New freshness threshold in seconds.
     */
    function setMaxPriceAge(uint256 newMaxPriceAge) external onlyRole(ORACLE_ADMIN_ROLE) {
        if (newMaxPriceAge == 0) revert InvalidManualPrice();
        maxPriceAge = newMaxPriceAge;
        emit MaxPriceAgeUpdated(newMaxPriceAge);
    }

    /**
     * @notice Stores the manual ICFT/USD price after validation.
     * @param price Raw manual price value.
     * @param decimals_ Decimals used by the raw manual price.
     */
    function _setManualICFTPrice(uint256 price, uint8 decimals_) internal {
        if (price == 0) revert InvalidManualPrice();
        if (decimals_ > 18) revert UnsupportedPriceDecimals();

        // Persist raw manual pricing inputs so the original admin-provided value remains inspectable.
        manualICFTPrice = price;
        manualICFTPriceDecimals = decimals_;

        // Emit both raw and normalized values for offchain monitoring and auditability.
        emit ICFTPriceUpdated(price, decimals_, normalizePrice(price, decimals_));
    }

    /**
     * @notice Reads a Chainlink price feed and validates freshness and sign.
     * @param feed Chainlink aggregator to query.
     * @return normalizedPrice Feed answer normalized to 1e18 precision.
     */
    function _getChainlinkPrice(AggregatorV3Interface feed) internal view returns (uint256) {
        if (address(feed) == address(0)) revert InvalidOracleAddress();

        (, int256 answer,, uint256 updatedAt,) = feed.latestRoundData();

        // Reject unusable or stale oracle answers before converting them into protocol accounting units.
        if (answer <= 0 || updatedAt == 0) revert InvalidOracleAnswer();
        if (block.timestamp > updatedAt + maxPriceAge) revert StaleOraclePrice();

        return normalizePrice(uint256(answer), feed.decimals());
    }

    /**
     * @notice Converts a token-denominated amount into internal USD units.
     * @param tokenAmount Token amount using 18 token decimals.
     * @param tokenPrice Token/USD price using 1e18 precision.
     * @return usdAmount Equivalent internal USD value.
     */
    function _convertTokenToUSD(uint256 tokenAmount, uint256 tokenPrice) internal pure returns (uint256) {
        return (tokenAmount * tokenPrice) / INTERNAL_PRICE_PRECISION;
    }

    /**
     * @notice Converts an internal USD amount into a token-denominated amount.
     * @param usdAmount Internal USD amount using 1e18 precision.
     * @param tokenPrice Token/USD price using 1e18 precision.
     * @param roundUp Whether to round up the result to avoid underpayment.
     * @return tokenAmount Equivalent token amount using 18 token decimals.
     */
    function _convertUSDToToken(uint256 usdAmount, uint256 tokenPrice, bool roundUp) internal pure returns (uint256) {
        if (tokenPrice == 0) revert InvalidOracleAnswer();

        uint256 numerator = usdAmount * INTERNAL_PRICE_PRECISION;
        uint256 result = numerator / tokenPrice;

        if (roundUp && numerator % tokenPrice != 0) {
            result += 1;
        }

        return result;
    }
}
