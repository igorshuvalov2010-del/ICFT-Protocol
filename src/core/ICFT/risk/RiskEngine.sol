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

import {IPriceOracle} from "../../interfaces/IPriceOracle.sol";
import {IRiskEngine} from "../../interfaces/IRiskEngine.sol";
import {InvalidAddress, InvalidRiskParameters} from "../../utils/Errors.sol";

/**
 * @title RiskEngine
 * @notice Computes collateral value, borrow capacity, LTV, and liquidation sizing.
 * @dev All USD values in this contract use the protocol's internal 1e18 accounting unit.
 * @dev Collateral valuation is generic across supported assets while health checks operate on aggregate USD values.
 * @dev Liquidation sizing attempts to move a position toward the configured target LTV while applying the bonus.
 *
 * @custom:version 1.2.0
 */
contract RiskEngine is Initializable, IRiskEngine, AccessControlUpgradeable {
    bytes32 public constant RISK_ADMIN_ROLE = keccak256("RISK_ADMIN_ROLE");
    uint256 public constant BPS = 10_000;

    IPriceOracle public priceOracle;
    uint256 public maxLtvBps;
    uint256 public liquidationThresholdBps;
    uint256 public targetLtvBps;
    uint256 public liquidationBonusBps;

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    function initialize(
        address admin,
        address priceOracle_,
        uint256 maxLtvBps_,
        uint256 liquidationThresholdBps_,
        uint256 targetLtvBps_,
        uint256 liquidationBonusBps_
    ) external initializer {
        if (admin == address(0) || priceOracle_ == address(0)) revert InvalidAddress();

        __AccessControl_init();

        _grantRole(DEFAULT_ADMIN_ROLE, admin);
        _grantRole(RISK_ADMIN_ROLE, admin);

        priceOracle = IPriceOracle(priceOracle_);
        _setRiskParameters(maxLtvBps_, liquidationThresholdBps_, targetLtvBps_, liquidationBonusBps_);
    }

    function getCollateralValueUSD(address collateralAsset, uint256 collateralAmount)
        public
        view
        returns (uint256 collateralValueUSD)
    {
        return priceOracle.convertAssetToUSD(collateralAsset, collateralAmount);
    }

    function getMaxBorrowUSD(uint256 collateralValueUSD) external view returns (uint256) {
        return (collateralValueUSD * maxLtvBps) / BPS;
    }

    function calculateLTV(uint256 collateralValueUSD, uint256 debtUSD) public view returns (uint256) {
        if (debtUSD == 0) return 0;
        if (collateralValueUSD == 0) return type(uint256).max;

        return (debtUSD * BPS) / collateralValueUSD;
    }

    function isLiquidatable(uint256 collateralValueUSD, uint256 debtUSD) external view returns (bool) {
        return calculateLTV(collateralValueUSD, debtUSD) >= liquidationThresholdBps;
    }

    function calculateLiquidation(uint256 collateralValueUSD, uint256 debtUSD)
        external
        view
        returns (LiquidationOutcome memory outcome)
    {
        uint256 currentLtvBps = calculateLTV(collateralValueUSD, debtUSD);

        if (collateralValueUSD == 0 || debtUSD == 0 || currentLtvBps < liquidationThresholdBps) {
            return outcome;
        }

        if (_isAlreadyAtTarget(collateralValueUSD, debtUSD)) {
            outcome.resultingLtvBps = currentLtvBps;
            return outcome;
        }

        uint256 denominator = (BPS * BPS) - (targetLtvBps * (BPS + liquidationBonusBps));
        if (denominator == 0) revert InvalidRiskParameters();

        uint256 numerator = (debtUSD * BPS * BPS) - (targetLtvBps * collateralValueUSD * BPS);
        uint256 debtToCoverUSD = numerator / denominator;
        if (numerator % denominator != 0) {
            debtToCoverUSD += 1;
        }
        if (debtToCoverUSD > debtUSD) {
            debtToCoverUSD = debtUSD;
        }

        uint256 collateralValueToSeizeUSD = (debtToCoverUSD * (BPS + liquidationBonusBps)) / BPS;
        if (collateralValueToSeizeUSD > collateralValueUSD) {
            collateralValueToSeizeUSD = collateralValueUSD;
        }

        uint256 remainingDebtUSD = debtUSD > debtToCoverUSD ? debtUSD - debtToCoverUSD : 0;
        uint256 remainingCollateralValueUSD =
            collateralValueUSD > collateralValueToSeizeUSD ? collateralValueUSD - collateralValueToSeizeUSD : 0;

        outcome = LiquidationOutcome({
            debtToCoverUSD: debtToCoverUSD,
            collateralValueSeizedUSD: collateralValueToSeizeUSD,
            resultingLtvBps: calculateLTV(remainingCollateralValueUSD, remainingDebtUSD)
        });
    }

    function getMaxLTVBps() external view returns (uint256) {
        return maxLtvBps;
    }

    function getLiquidationThresholdBps() external view returns (uint256) {
        return liquidationThresholdBps;
    }

    function getTargetLTVBps() external view returns (uint256) {
        return targetLtvBps;
    }

    function getLiquidationBonusBps() external view returns (uint256) {
        return liquidationBonusBps;
    }

    function setRiskParameters(
        uint256 maxLtvBps_,
        uint256 liquidationThresholdBps_,
        uint256 targetLtvBps_,
        uint256 liquidationBonusBps_
    ) external onlyRole(RISK_ADMIN_ROLE) {
        _setRiskParameters(maxLtvBps_, liquidationThresholdBps_, targetLtvBps_, liquidationBonusBps_);
    }

    function _setRiskParameters(
        uint256 maxLtvBps_,
        uint256 liquidationThresholdBps_,
        uint256 targetLtvBps_,
        uint256 liquidationBonusBps_
    ) internal {
        bool invalid = maxLtvBps_ == 0
            || maxLtvBps_ >= liquidationThresholdBps_
            || targetLtvBps_ > liquidationThresholdBps_
            || liquidationThresholdBps_ > BPS
            || liquidationBonusBps_ > BPS;

        if (invalid) revert InvalidRiskParameters();

        maxLtvBps = maxLtvBps_;
        liquidationThresholdBps = liquidationThresholdBps_;
        targetLtvBps = targetLtvBps_;
        liquidationBonusBps = liquidationBonusBps_;

        emit RiskParametersUpdated(maxLtvBps_, liquidationThresholdBps_, targetLtvBps_, liquidationBonusBps_);
    }

    function _isAlreadyAtTarget(uint256 collateralValueUSD, uint256 debtUSD) internal view returns (bool alreadyAtTarget) {
        return debtUSD * BPS * BPS <= targetLtvBps * collateralValueUSD * BPS;
    }
}
