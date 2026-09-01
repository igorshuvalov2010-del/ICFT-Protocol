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
import {ERC20Upgradeable} from "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
import {InvalidRecipient, InvalidTokenAllocation} from "../../utils/Errors.sol";

/**
 * @title ICFT
 * @notice Fixed-supply ERC-20 token used by the ICFT MVP lending protocol.
 * @dev The contract mints the entire supply once during construction and never mints again.
 * @dev Allocation constants encode the requested tokenomics split used by the MVP deployment flow.
 *
 * @custom:version 1.0.0
 */
contract ICFT is Initializable, ERC20Upgradeable {
    /// @notice Total fixed token supply minted once at deployment.
    uint256 public constant TOTAL_SUPPLY = 1_000_000_000 ether;

    /// @notice Allocation reserved for Fund A lending liquidity.
    uint256 public constant FUND_A_ALLOCATION = 200_000_000 ether;
    /// @notice Allocation reserved for liquid market and operational liquidity.
    uint256 public constant LIQUIDITY_ALLOCATION = 150_000_000 ether;
    /// @notice Allocation reserved for strategic reserves.
    uint256 public constant STRATEGIC_RESERVE_ALLOCATION = 280_000_000 ether;
    /// @notice Allocation reserved for future investor distribution.
    uint256 public constant FUTURE_INVESTORS_ALLOCATION = 160_000_000 ether;
    /// @notice Allocation reserved for founders.
    uint256 public constant FOUNDER_ALLOCATION = 80_000_000 ether;
    /// @notice Allocation reserved for developers and core contributors.
    uint256 public constant DEVELOPERS_ALLOCATION = 100_000_000 ether;
    /// @notice Allocation reserved for ecosystem grants and growth programs.
    uint256 public constant ECOSYSTEM_GRANTS_ALLOCATION = 30_000_000 ether;

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    /**
     * @notice Mints the full fixed supply according to the requested allocation split.
     * @param fundARecipient Recipient of the Fund A allocation.
     * @param liquidityRecipient Recipient of the liquidity allocation.
     * @param strategicReserveRecipient Recipient of the strategic reserve allocation.
     * @param futureInvestorsRecipient Recipient of the future investors allocation.
     * @param founderRecipient Recipient of the founder allocation.
     * @param developersRecipient Recipient of the developers allocation.
     * @param ecosystemRecipient Recipient of the ecosystem grants allocation.
     */
    function initialize(
        address fundARecipient,
        address liquidityRecipient,
        address strategicReserveRecipient,
        address futureInvestorsRecipient,
        address founderRecipient,
        address developersRecipient,
        address ecosystemRecipient
    ) external initializer {
        __ERC20_init("ICFT", "ICFT");

        if (
            fundARecipient == address(0) ||
            liquidityRecipient == address(0) ||
            strategicReserveRecipient == address(0) ||
            futureInvestorsRecipient == address(0) ||
            founderRecipient == address(0) ||
            developersRecipient == address(0) ||
            ecosystemRecipient == address(0)
        ) revert InvalidRecipient();

        // Mint the full tokenomics split in a single deterministic construction flow.
        _mint(fundARecipient, FUND_A_ALLOCATION);
        _mint(liquidityRecipient, LIQUIDITY_ALLOCATION);
        _mint(strategicReserveRecipient, STRATEGIC_RESERVE_ALLOCATION);
        _mint(futureInvestorsRecipient, FUTURE_INVESTORS_ALLOCATION);
        _mint(founderRecipient, FOUNDER_ALLOCATION);
        _mint(developersRecipient, DEVELOPERS_ALLOCATION);
        _mint(ecosystemRecipient, ECOSYSTEM_GRANTS_ALLOCATION);

        // Enforce that the static allocation constants fully reconstruct the intended total supply.
        if (totalSupply() != TOTAL_SUPPLY) revert InvalidTokenAllocation();
    }
}
