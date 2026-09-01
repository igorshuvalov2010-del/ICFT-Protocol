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
//                                                     .,itTTTTTTTTl:.
//                                           .;iFYCLJYYUXnF!Ii;iI!FnYJCCQwqwnli.
//                                       lxvUXFtl,.........................,!frQqCzf
//                                  .;zzcr:.......................................,uLwml,
//                               IjznT:...............................................:jXmvt
//                            ;cXn:.......................................................,vLJl
//                         ;rUni.............................................................;uJui
//                       IUUI...................................................................IYUl
//                     fJv;.......................................................................,nYT
//                   TLU:...........................................................................:cX!
//                 !QXi...............................................................................;nzI
//                CQi...................................................................................;vu
//             .xwx.......................................................................................TvT
//             JY,...................................;vCLwbkkkkkbkkkkdmCCj,................................,rr
//           !wv...............................,iFpdddpmQQQLCCLQQQmqbbbddddddYl:.............................Tni
//          jw!.............................,jYwwcf!..................lfvqqqqqwqLc:...........................in!
//         UQ!..........................,,lQLz,.............................XLmmQmQwl,.........................irj
//       .vw;..........................,xLu;..................................:xCQQQQLc.........................:xT.
//       nm:.........................,jQ:........................................,LQQQQQv........................,rT
//      vLl.........................tc!............................................IcLLLLLf.......................;rT
//     rwl.........................z!................................................lYJJUJr,......................;x!
//    iLF........................lj...................................................,jYYYYU:......................lr,
//    Jc:.......................:!......................................................!YUUUYl......................Tj
//   tQt.......................!,........................................................,JJJJU;.....................ixI
//   CY.......................I:..........................................................;UCLCL......................jr
//  jQ:......................,:............................................................tccccu.....................,n!
// .nX......................................,;;,.......................................................................rT
// ;Li.................:ppm:..........:Tqbbdddpppqqm!;.......hoooooooooooooooooqI,vaoooooooooooooooooobT...............;u,
// IC;.................:ddw:........lUbbbbQrFFFfxmqwwwUi.....hoooaaoooooaoaaaak:.YaooaoaaooaaaaaooaaoaI................:v:
// xv,.................:bbq:.......nbbdU,..........:CQ!......kaam.........................Ihhpl........................,rt
// Uj..................:bbq:.....:QddL;...IF!utTf............bkkm.........................Ikkql.........................fn
// JF..................:ddw:....,vppc,..,u,X,v.II,x,.........dbbm.........................Ibbwl.........................Tz
// Uf..................:ppm:....IqqLI..t,.F,.c,.!,.F.........qddm.........................Iddml.........................fX
// Uf..................:wwQ:....!wwJ..::.::..z...n..v........wpqqwwwwwwwwwwwmT............ippQl.........................fY
// Xf.................,:mmC:....ImmU..,;.,;..c,..x..r........mqwqwwqqqqqqqqp!.............iqqQl.........................FU
// Xf..................:LLJ:...,ILLCT..t,.F,.x..t,.x.........mwwQ::::::::::...............iwwLl.........................jJ
// xj..................:CJY:.....rCJz:..:F;F,j,;;iF:.........QmmL.........................iQQCl........................,un
// Iv:.................:UUX:.....,vUUUT...:,Trfl;,...........LQmQ.........................iQQJl........................;JI
// :c:.................:XXc:.......lzXXU!:........:!XYni.....QmmQ.........................iQmCl........................iQi
// .jf.................,zcv,........,lzzzzznxxxxnczzzzf......QmmQ.........................immCl........................uc,
//  tv.................,Fjf,............FnucccvvcunT.........UJJY.........................iJJXI........................wx
//  ,xf.....................innni,....................................................................................zQ:
//   tj:....................,jCJUT........................,.................................l........................iQu
//    xt......................rJCLT.....................................,.................,I,.......................,um
//    :x:......................jJCCQ,....................................................,Y.........................ipI
//     lr:......................;XCCJt..................................................tf.........................;qn
//      FF,.......................XCCLU;...............................................U;.........................,JL
//       fT........................;XLLLYT.................................,.........un..........................,XU
//       .Tj.........................;LQQQQF......................................:zX:...........................QY:
//         fF:.........................ivmmmmYF,...............................:fQr,...........................;JL.
//          lj,..........................,IQqqqqQQl.........................izQYI.............................,Qv
//           Irl.............................iUmdddddputti...........:lTFQpLc;...............................tqx
//            .rF................................ITcbkkkkkkkkkbddbkkkkpnTi..................................cwI
//              txl........................................:IlI:..........................................iwc,
//               ,rj.....................................................................................Xm!
//                 tuF................................................................................,umu
//                   fuT.............................................................................xmv.
//                     Tcr,........................................................................fQU
//                       !znI...................................................................;Xmj,
//                         :uXr,..............................................................jQCl
//                            !cXj:.......................................................,FLLj.
//                              .lYJz; ............................................... ,cLQf,
//                                  inYLnt;.......................................:tjLCvl
//                                      ;tJmCUx,..............................TUJmLTi.
//                                           .tXYQqqLnT!t!Ii;;::;iIl!!tjUmmLYXj,
pragma solidity ^0.8.20;

import {Initializable} from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import {AccessControlUpgradeable} from "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

import {IPriceOracle} from "../../interfaces/IPriceOracle.sol";
import {
    InvalidAssetDecimals,
    InvalidManualPrice,
    InvalidOracleAddress,
    InvalidOracleAnswer,
    StaleOraclePrice,
    UnsupportedCollateralAsset,
    UnsupportedPriceDecimals
} from "../../utils/Errors.sol";
import {PriceSource} from "../../utils/PriceSource.sol";

/**
 * @title PriceOracle
 * @notice Provides native ETH/USD, ICFT/USD, and ERC20 collateral/USD prices normalized to 1e18 precision.
 * @dev The protocol uses USD as an internal accounting unit, not as a stablecoin token balance.
 * @dev Native ETH is represented by the zero address in generic collateral conversion helpers.
 * @dev ERC20 collateral support is feed-driven so assets like wBTC and wstETH can be added without rewriting risk math.
 * @dev Manual ICFT pricing exists for MVP and early testnet deployments where no trustworthy onchain market feed is available yet.
 *
 * @custom:version 1.2.0
 */
contract PriceOracle is Initializable, IPriceOracle, AccessControlUpgradeable {
    bytes32 public constant ORACLE_ADMIN_ROLE = keccak256("ORACLE_ADMIN_ROLE");
    uint256 public constant INTERNAL_PRICE_PRECISION = 1e18;

    struct CollateralFeedConfig {
        AggregatorV3Interface feed;
        uint8 assetDecimals;
        bool enabled;
    }

    AggregatorV3Interface public ethUsdFeed;
    AggregatorV3Interface public icftUsdFeed;
    PriceSource public icftPriceSource = PriceSource.Manual;
    uint256 public manualICFTPrice;
    uint8 public manualICFTPriceDecimals;
    uint256 public maxPriceAge;

    // Append-only storage layout for proxy safety:
    // collateralFeeds must remain after legacy oracle fields so Sepolia proxy
    // state from the earlier oracle version is interpreted correctly.
    mapping(address => CollateralFeedConfig) internal collateralFeeds;

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    function initialize(
        address admin,
        address ethUsdFeed_,
        uint256 maxPriceAge_,
        uint256 initialManualICFTPrice,
        uint8 initialManualICFTPriceDecimals
    ) external initializer {
        if (admin == address(0) || ethUsdFeed_ == address(0)) revert InvalidOracleAddress();
        if (maxPriceAge_ == 0) revert InvalidManualPrice();

        __AccessControl_init();

        _grantRole(DEFAULT_ADMIN_ROLE, admin);
        _grantRole(ORACLE_ADMIN_ROLE, admin);

        ethUsdFeed = AggregatorV3Interface(ethUsdFeed_);
        maxPriceAge = maxPriceAge_;
        _setManualICFTPrice(initialManualICFTPrice, initialManualICFTPriceDecimals);
    }

    function getETHUSDPrice() external view returns (uint256) {
        return _getChainlinkPrice(ethUsdFeed);
    }

    function getAssetUSDPrice(address asset) public view returns (uint256) {
        if (asset == address(0)) {
            return _getChainlinkPrice(ethUsdFeed);
        }

        CollateralFeedConfig memory config = collateralFeeds[asset];
        if (!config.enabled) revert UnsupportedCollateralAsset();

        return _getChainlinkPrice(config.feed);
    }

    function getAssetDecimals(address asset) public view returns (uint8 decimals) {
        if (asset == address(0)) {
            return 18;
        }

        CollateralFeedConfig memory config = collateralFeeds[asset];
        if (!config.enabled) revert UnsupportedCollateralAsset();

        return config.assetDecimals;
    }

    function isCollateralAssetSupported(address asset) external view returns (bool supported) {
        if (asset == address(0)) {
            return address(ethUsdFeed) != address(0);
        }

        return collateralFeeds[asset].enabled;
    }

    function getICFTUSDPrice() external view returns (uint256) {
        if (icftPriceSource == PriceSource.Manual) {
            return normalizePrice(manualICFTPrice, manualICFTPriceDecimals);
        }

        return _getChainlinkPrice(icftUsdFeed);
    }

    function getICFTPriceSource() external view returns (PriceSource) {
        return icftPriceSource;
    }

    function normalizePrice(uint256 price, uint8 priceDecimals) public pure returns (uint256) {
        if (price == 0) revert InvalidOracleAnswer();
        if (priceDecimals > 18) revert UnsupportedPriceDecimals();

        if (priceDecimals == 18) {
            return price;
        }

        return price * (10 ** (18 - priceDecimals));
    }

    function convertICFTToUSD(uint256 icftAmount) external view returns (uint256) {
        return _convertTokenToUSD(icftAmount, this.getICFTUSDPrice());
    }

    function convertUSDToICFT(uint256 usdAmount, bool roundUp) external view returns (uint256) {
        return _convertUSDToToken(usdAmount, this.getICFTUSDPrice(), roundUp);
    }

    function convertAssetToUSD(address asset, uint256 assetAmount) external view returns (uint256 usdAmount) {
        uint256 normalizedAmount = _normalizeTokenAmount(assetAmount, getAssetDecimals(asset));
        return _convertTokenToUSD(normalizedAmount, getAssetUSDPrice(asset));
    }

    function convertUSDToAsset(address asset, uint256 usdAmount, bool roundUp)
        external
        view
        returns (uint256 assetAmount)
    {
        uint256 normalizedAmount = _convertUSDToToken(usdAmount, getAssetUSDPrice(asset), roundUp);
        return _denormalizeTokenAmount(normalizedAmount, getAssetDecimals(asset), roundUp);
    }

    function setManualICFTPrice(uint256 price, uint8 decimals_) external onlyRole(ORACLE_ADMIN_ROLE) {
        _setManualICFTPrice(price, decimals_);
    }

    function setNativeUSDFeed(address feed) external onlyRole(ORACLE_ADMIN_ROLE) {
        if (feed == address(0)) revert InvalidOracleAddress();

        ethUsdFeed = AggregatorV3Interface(feed);
        emit NativeUSDFeedUpdated(feed);
    }

    function setICFTUSDFeed(address feed) external onlyRole(ORACLE_ADMIN_ROLE) {
        if (feed == address(0)) revert InvalidOracleAddress();
        icftUsdFeed = AggregatorV3Interface(feed);
        emit ICFTUSDFeedUpdated(feed);
    }

    function setCollateralAssetFeed(address asset, address feed, uint8 assetDecimals, bool enabled)
        external
        onlyRole(ORACLE_ADMIN_ROLE)
    {
        if (asset == address(0) || feed == address(0)) revert InvalidOracleAddress();
        if (assetDecimals > 18) revert InvalidAssetDecimals();

        collateralFeeds[asset] =
            CollateralFeedConfig({feed: AggregatorV3Interface(feed), assetDecimals: assetDecimals, enabled: enabled});

        emit CollateralAssetFeedUpdated(asset, feed, assetDecimals, enabled);
    }

    function setICFTPriceSource(PriceSource source) external onlyRole(ORACLE_ADMIN_ROLE) {
        if (source == PriceSource.Chainlink && address(icftUsdFeed) == address(0)) {
            revert InvalidOracleAddress();
        }

        icftPriceSource = source;
        emit OracleSourceUpdated(source);
    }

    function setMaxPriceAge(uint256 newMaxPriceAge) external onlyRole(ORACLE_ADMIN_ROLE) {
        if (newMaxPriceAge == 0) revert InvalidManualPrice();
        maxPriceAge = newMaxPriceAge;
        emit MaxPriceAgeUpdated(newMaxPriceAge);
    }

    function _setManualICFTPrice(uint256 price, uint8 decimals_) internal {
        if (price == 0) revert InvalidManualPrice();
        if (decimals_ > 18) revert UnsupportedPriceDecimals();

        manualICFTPrice = price;
        manualICFTPriceDecimals = decimals_;

        emit ICFTPriceUpdated(price, decimals_, normalizePrice(price, decimals_));
    }

    function _getChainlinkPrice(AggregatorV3Interface feed) internal view returns (uint256 normalizedPrice) {
        if (address(feed) == address(0)) revert InvalidOracleAddress();

        (, int256 answer,, uint256 updatedAt,) = feed.latestRoundData();

        if (answer <= 0 || updatedAt == 0) revert InvalidOracleAnswer();
        if (block.timestamp > updatedAt + maxPriceAge) revert StaleOraclePrice();

        return normalizePrice(uint256(answer), feed.decimals());
    }

    function _convertTokenToUSD(uint256 tokenAmount, uint256 tokenPrice) internal pure returns (uint256 usdAmount) {
        return (tokenAmount * tokenPrice) / INTERNAL_PRICE_PRECISION;
    }

    function _convertUSDToToken(uint256 usdAmount, uint256 tokenPrice, bool roundUp)
        internal
        pure
        returns (uint256 tokenAmount)
    {
        if (tokenPrice == 0) revert InvalidOracleAnswer();

        uint256 numerator = usdAmount * INTERNAL_PRICE_PRECISION;
        uint256 result = numerator / tokenPrice;

        if (roundUp && numerator % tokenPrice != 0) {
            result += 1;
        }

        return result;
    }

    function _normalizeTokenAmount(uint256 amount, uint8 amountDecimals)
        internal
        pure
        returns (uint256 normalizedAmount)
    {
        if (amountDecimals > 18) revert InvalidAssetDecimals();

        if (amountDecimals == 18) {
            return amount;
        }

        return amount * (10 ** (18 - amountDecimals));
    }

    function _denormalizeTokenAmount(uint256 normalizedAmount, uint8 amountDecimals, bool roundUp)
        internal
        pure
        returns (uint256 rawAmount)
    {
        if (amountDecimals > 18) revert InvalidAssetDecimals();

        if (amountDecimals == 18) {
            return normalizedAmount;
        }

        uint256 divisor = 10 ** (18 - amountDecimals);
        rawAmount = normalizedAmount / divisor;

        if (roundUp && normalizedAmount % divisor != 0) {
            rawAmount += 1;
        }
    }
}
