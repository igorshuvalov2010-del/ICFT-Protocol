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

import {IInterestRateModel} from "../../interfaces/IInterestRateModel.sol";
import {InvalidAddress, InvalidRateConfig} from "../../utils/Errors.sol";

/**
 * @title InterestRateModel
 * @notice Defines the utilization-based borrow APR curve for ICFT loans.
 * @dev The model uses a four-bucket piecewise curve selected by utilization thresholds.
 * @dev Rates are expressed in basis points and are intended to be consumed by the lending pool during accrual.
 *
 * @custom:version 1.0.0
 */
contract InterestRateModel is Initializable, IInterestRateModel, AccessControlUpgradeable {
    /// @notice Role allowed to update the utilization curve configuration.
    bytes32 public constant RATE_ADMIN_ROLE = keccak256("RATE_ADMIN_ROLE");

    /// @notice Basis-point denominator used for utilization and APR values.
    uint256 public constant BPS = 10_000;

    /// @notice Active utilization curve configuration.
    RateConfig public rateConfig;

    /**
     * @notice Creates the rate model with the initial piecewise utilization curve.
     * @param admin Address that receives admin and rate-admin roles.
     * @param initialConfig Initial borrow-curve configuration.
     */
    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    function initialize(address admin, RateConfig memory initialConfig) external initializer {
        if (admin == address(0)) revert InvalidAddress();

        __AccessControl_init();

        _grantRole(DEFAULT_ADMIN_ROLE, admin);
        _grantRole(RATE_ADMIN_ROLE, admin);
        _setRateConfig(initialConfig);
    }

    /// @inheritdoc IInterestRateModel
    function getBorrowRateBps(uint256 utilizationBps) external view returns (uint256) {
        RateConfig memory config = rateConfig;

        if (utilizationBps < config.kink1Bps) return config.rate1Bps;
        if (utilizationBps < config.kink2Bps) return config.rate2Bps;
        if (utilizationBps < config.kink3Bps) return config.rate3Bps;
        return config.rate4Bps;
    }

    /// @inheritdoc IInterestRateModel
    function getMaxBorrowUtilizationBps() external view returns (uint256) {
        return rateConfig.maxBorrowUtilizationBps;
    }

    /**
     * @notice Updates the borrow curve configuration.
     * @param newConfig Complete replacement rate configuration.
     */
    function setRateConfig(RateConfig memory newConfig) external onlyRole(RATE_ADMIN_ROLE) {
        _setRateConfig(newConfig);
    }

    /**
     * @notice Validates and stores a new utilization curve.
     * @param newConfig Proposed rate configuration.
     */
    function _setRateConfig(RateConfig memory newConfig) internal {
        bool validOrder = newConfig.kink1Bps < newConfig.kink2Bps
            && newConfig.kink2Bps < newConfig.kink3Bps
            && newConfig.kink3Bps <= BPS
            && newConfig.maxBorrowUtilizationBps <= BPS;

        bool validRates = newConfig.rate1Bps <= newConfig.rate2Bps
            && newConfig.rate2Bps <= newConfig.rate3Bps
            && newConfig.rate3Bps <= newConfig.rate4Bps;

        if (!validOrder || !validRates || newConfig.maxBorrowUtilizationBps < newConfig.kink3Bps) {
            revert InvalidRateConfig();
        }

        // Replace the entire rate curve atomically so accrual always sees a coherent configuration.
        rateConfig = newConfig;
        emit RateConfigUpdated(newConfig);
    }
}
