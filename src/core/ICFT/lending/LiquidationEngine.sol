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
import {ReentrancyGuardUpgradeable} from "@openzeppelin/contracts-upgradeable/utils/ReentrancyGuardUpgradeable.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

import {ILiquidationEngine} from "../../interfaces/ILiquidationEngine.sol";
import {ILendingPool} from "../../interfaces/ILendingPool.sol";
import {IPriceOracle} from "../../interfaces/IPriceOracle.sol";
import {IRiskEngine} from "../../interfaces/IRiskEngine.sol";
import {EthTransferFailed, InvalidAddress, InvalidAmount, MaxRepayBelowRequired} from "../../utils/Errors.sol";

/**
 * @title LiquidationEngine
 * @notice Restricted liquidation helper that repays ICFT debt and routes seized collateral to the chosen beneficiary.
 * @dev The helper wraps the pool's liquidation entrypoint so operators can work from a richer preview surface.
 * @dev Collateral is selected explicitly per execution because user baskets can now contain ETH, wBTC, wstETH, and future assets.
 * @dev Access is intentionally role-restricted for the MVP bot-driven liquidation model.
 *
 * @custom:version 1.2.0
 */
contract LiquidationEngine is Initializable, ILiquidationEngine, AccessControlUpgradeable, ReentrancyGuardUpgradeable {
    using SafeERC20 for IERC20;

    struct ExecutionSnapshot {
        uint256 debtBefore;
        uint256 collateralBefore;
        uint256 icftBefore;
        uint256 requestedTransfer;
    }

    struct ExecutionOutcome {
        uint256 repaidIcft;
        uint256 repaidUsd;
        uint256 seizedCollateralAmount;
        uint256 debtAfter;
    }

    struct FinalizationParams {
        address user;
        address collateralAsset;
        address payable collateralBeneficiary;
        uint256 requestedTransfer;
        uint256 repaidIcft;
        uint256 repaidUsd;
        uint256 seizedCollateralAmount;
        uint256 debtAfter;
    }

    bytes32 public constant ENGINE_ADMIN_ROLE = keccak256("ENGINE_ADMIN_ROLE");
    bytes32 public constant OPERATOR_ROLE = keccak256("OPERATOR_ROLE");

    IERC20 public icft;
    ILendingPool public lendingPool;

    uint256 public totalExecutions;
    uint256 public totalRepaidIcft;
    uint256 public totalRepaidUsd;
    mapping(address => uint256) public totalSeizedByAsset;

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    function initialize(address admin, address icft_, address lendingPool_) external initializer {
        if (admin == address(0) || icft_ == address(0) || lendingPool_ == address(0)) revert InvalidAddress();

        __AccessControl_init();
        __ReentrancyGuard_init();

        _grantRole(DEFAULT_ADMIN_ROLE, admin);
        _grantRole(ENGINE_ADMIN_ROLE, admin);
        _grantRole(OPERATOR_ROLE, admin);

        icft = IERC20(icft_);
        lendingPool = ILendingPool(lendingPool_);
    }

    receive() external payable {}

    function recoverNative(address payable recipient, uint256 amount) external onlyRole(ENGINE_ADMIN_ROLE) {
        if (recipient == address(0)) revert InvalidAddress();
        if (amount == 0) revert InvalidAmount();

        (bool success,) = recipient.call{value: amount}("");
        if (!success) revert EthTransferFailed();

        emit NativeRecovered(recipient, amount);
    }

    function previewLiquidation(address user, address collateralAsset)
        external
        view
        returns (LiquidationPreview memory preview)
    {
        uint256 debtUsd = lendingPool.getDebt(user);
        bool liquidatable = lendingPool.isLiquidatable(user);

        preview.isLiquidatable = liquidatable;
        preview.collateralAsset = collateralAsset;
        preview.debtUsd = debtUsd;

        if (!liquidatable || debtUsd == 0) {
            return preview;
        }

        uint256 collateralBalance = lendingPool.getCollateralBalance(user, collateralAsset);
        if (collateralBalance == 0) {
            return preview;
        }

        uint256 totalCollateralValueUsd = lendingPool.getCollateralValueUSD(user);
        IRiskEngine.LiquidationOutcome memory genericOutcome =
            IRiskEngine(lendingPool.riskEngine()).calculateLiquidation(totalCollateralValueUsd, debtUsd);

        if (genericOutcome.debtToCoverUSD == 0 || genericOutcome.collateralValueSeizedUSD == 0) {
            return preview;
        }

        uint256 assetValueUsd =
            IRiskEngine(lendingPool.riskEngine()).getCollateralValueUSD(collateralAsset, collateralBalance);
        uint256 desiredSeizedValueUsd =
            genericOutcome.collateralValueSeizedUSD < assetValueUsd ? genericOutcome.collateralValueSeizedUSD : assetValueUsd;
        uint256 seizeAmount =
            IPriceOracle(lendingPool.priceOracle()).convertUSDToAsset(collateralAsset, desiredSeizedValueUsd, false);

        if (seizeAmount == 0 && desiredSeizedValueUsd > 0) {
            seizeAmount = 1;
        }
        if (seizeAmount > collateralBalance) {
            seizeAmount = collateralBalance;
        }

        uint256 actualSeizedValueUsd =
            IRiskEngine(lendingPool.riskEngine()).getCollateralValueUSD(collateralAsset, seizeAmount);
        uint256 repaidUsd =
            (actualSeizedValueUsd * 10_000) / (10_000 + IRiskEngine(lendingPool.riskEngine()).getLiquidationBonusBps());
        uint256 remainingDebtUsd = debtUsd > repaidUsd ? debtUsd - repaidUsd : 0;
        uint256 remainingCollateralValueUsd =
            totalCollateralValueUsd > actualSeizedValueUsd ? totalCollateralValueUsd - actualSeizedValueUsd : 0;

        preview.requiredIcft = IPriceOracle(lendingPool.priceOracle()).convertUSDToICFT(repaidUsd, true);
        preview.collateralToSeizeAmount = seizeAmount;
        preview.collateralValueSeizedUsd = actualSeizedValueUsd;
        preview.resultingLtvBps =
            IRiskEngine(lendingPool.riskEngine()).calculateLTV(remainingCollateralValueUsd, remainingDebtUsd);
    }

    function executeLiquidation(
        address user,
        address collateralAsset,
        uint256 maxIcftToRepay,
        address payable collateralBeneficiary
    ) external nonReentrant onlyRole(OPERATOR_ROLE) returns (uint256 repaidIcft, uint256 repaidUsd, uint256 seizedCollateralAmount)
    {
        if (collateralBeneficiary == address(0)) revert InvalidAddress();
        if (maxIcftToRepay == 0) revert InvalidAmount();

        ExecutionSnapshot memory snapshot = _snapshotExecution(user, collateralAsset);

        if (snapshot.requestedTransfer > maxIcftToRepay) {
            revert MaxRepayBelowRequired();
        }

        if (snapshot.requestedTransfer == 0) {
            snapshot.requestedTransfer = maxIcftToRepay;
        }

        icft.safeTransferFrom(msg.sender, address(this), snapshot.requestedTransfer);
        icft.forceApprove(address(lendingPool), 0);
        icft.forceApprove(address(lendingPool), snapshot.requestedTransfer);

        lendingPool.liquidate(user, collateralAsset, maxIcftToRepay, collateralBeneficiary);

        ExecutionOutcome memory outcome = _computeOutcome(snapshot, user, collateralAsset);
        repaidIcft = outcome.repaidIcft;
        repaidUsd = outcome.repaidUsd;
        seizedCollateralAmount = outcome.seizedCollateralAmount;
        _finalizeExecution(
            FinalizationParams({
                user: user,
                collateralAsset: collateralAsset,
                collateralBeneficiary: collateralBeneficiary,
                requestedTransfer: snapshot.requestedTransfer,
                repaidIcft: repaidIcft,
                repaidUsd: repaidUsd,
                seizedCollateralAmount: seizedCollateralAmount,
                debtAfter: outcome.debtAfter
            })
        );
    }

    function previewResultingLtv(address user) public view returns (uint256 ltvBps) {
        return _previewResultingLtvFromDebt(user, lendingPool.getDebt(user));
    }

    function _snapshotExecution(address user, address collateralAsset)
        internal
        view
        returns (ExecutionSnapshot memory snapshot)
    {
        snapshot.debtBefore = lendingPool.getDebt(user);
        snapshot.collateralBefore = lendingPool.getCollateralBalance(user, collateralAsset);
        snapshot.icftBefore = icft.balanceOf(address(this));
        snapshot.requestedTransfer = this.previewLiquidation(user, collateralAsset).requiredIcft;
    }

    function _computeOutcome(ExecutionSnapshot memory snapshot, address user, address collateralAsset)
        internal
        view
        returns (ExecutionOutcome memory outcome)
    {
        uint256 icftAfter = icft.balanceOf(address(this));
        uint256 refundIcft = icftAfter > snapshot.icftBefore ? icftAfter - snapshot.icftBefore : 0;

        outcome.debtAfter = lendingPool.getDebt(user);
        outcome.repaidUsd = snapshot.debtBefore > outcome.debtAfter ? snapshot.debtBefore - outcome.debtAfter : 0;
        outcome.repaidIcft = snapshot.requestedTransfer - refundIcft;

        uint256 collateralAfter = lendingPool.getCollateralBalance(user, collateralAsset);
        outcome.seizedCollateralAmount =
            snapshot.collateralBefore > collateralAfter ? snapshot.collateralBefore - collateralAfter : 0;
    }

    function _finalizeExecution(FinalizationParams memory params) internal {
        totalExecutions += 1;
        totalRepaidIcft += params.repaidIcft;
        totalRepaidUsd += params.repaidUsd;
        totalSeizedByAsset[params.collateralAsset] += params.seizedCollateralAmount;

        uint256 refundIcft = params.requestedTransfer - params.repaidIcft;
        if (refundIcft > 0) {
            icft.safeTransfer(msg.sender, refundIcft);
        }

        emit LiquidationExecuted(
            params.user,
            msg.sender,
            params.collateralAsset,
            params.collateralBeneficiary,
            params.repaidIcft,
            params.repaidUsd,
            params.seizedCollateralAmount,
            _previewResultingLtvFromDebt(params.user, params.debtAfter)
        );
    }

    function _previewResultingLtvFromDebt(address user, uint256 debtUsd) internal view returns (uint256 ltvBps) {
        return IRiskEngine(lendingPool.riskEngine()).calculateLTV(lendingPool.getCollateralValueUSD(user), debtUsd);
    }
}
