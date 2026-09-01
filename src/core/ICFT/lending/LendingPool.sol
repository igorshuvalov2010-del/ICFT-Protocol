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
import {PausableUpgradeable} from "@openzeppelin/contracts-upgradeable/utils/PausableUpgradeable.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {Address} from "@openzeppelin/contracts/utils/Address.sol";

import {IInterestRateModel} from "../../interfaces/IInterestRateModel.sol";
import {ILendingPool} from "../../interfaces/ILendingPool.sol";
import {IPriceOracle} from "../../interfaces/IPriceOracle.sol";
import {IRiskEngine} from "../../interfaces/IRiskEngine.sol";
import {
    BorrowExceedsLTV,
    BorrowingDisabledAtUtilization,
    DirectETHTransfersDisabled,
    InsufficientCollateral,
    InsufficientLiquidity,
    InvalidAddress,
    NoDebt,
    NothingToRepay,
    NotLiquidatable,
    SlippageExceeded,
    UnsupportedCollateralAsset,
    ZeroAmount
} from "../../utils/Errors.sol";

/**
 * @title LendingPool
 * @notice Accepts native ETH and oracle-approved ERC20 collateral while lending ICFT and tracking debt in internal USD units.
 * @dev The protocol borrows ICFT, not USDC or USDT. USD values are accounting-only 1e18 fixed-point numbers.
 * @dev Debt is stored in scaled units and accrued through a global borrow index so elapsed time is not repriced by a later utilization bucket.
 * @dev Native ETH is represented by the zero address inside generic collateral helpers and registries.
 * @dev Collateral health checks operate on the aggregate USD value of the full user basket across ETH, wBTC, wstETH, and future assets.
 * @dev Liquidations are restricted to an authorized bot role for the current operating model.
 *
 * @custom:version 1.2.0
 */
contract LendingPool is Initializable, ILendingPool, AccessControlUpgradeable, PausableUpgradeable, ReentrancyGuardUpgradeable {
    using Address for address payable;
    using SafeERC20 for IERC20;

    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");
    bytes32 public constant CONFIG_ADMIN_ROLE = keccak256("CONFIG_ADMIN_ROLE");
    bytes32 public constant LIQUIDATION_BOT_ROLE = keccak256("LIQUIDATION_BOT_ROLE");

    uint256 public constant BPS = 10_000;
    uint256 public constant YEAR = 365 days;
    uint256 public constant INDEX_SCALE = 1e18;
    address internal constant NATIVE_ASSET = address(0);

    struct LiquidationSettlement {
        uint256 debtToCoverUSD;
        uint256 collateralToSeizeAmount;
        uint256 collateralValueSeizedUSD;
        uint256 resultingLtvBps;
    }

    struct DebtSettlement {
        uint256 repaidPrincipalUSD;
        uint256 returnedPrincipalICFT;
        uint256 returnedRevenueICFT;
    }

    IERC20 public icft;
    IPriceOracle public priceOracle;
    IRiskEngine public riskEngine;
    IInterestRateModel public interestRateModel;

    uint256 public fundAAllocation;

    // Append-only storage layout:
    // keep legacy state fields in their original order so already deployed
    // proxies continue to read existing accounting values from the same slots.
    mapping(address => Position) public positions;

    uint256 public liquidityBuffer;
    uint256 public fundALiquidityICFT;
    uint256 public totalBorrowedICFT;
    uint256 public totalPrincipalDebtUSD;
    uint256 public totalScaledDebtUSD;
    uint256 public protocolRevenueICFT;
    uint256 public borrowIndex;
    uint256 public lastAccrualTime;

    mapping(address => mapping(address => uint256)) internal erc20CollateralBalances;
    mapping(address => CollateralAsset) internal collateralAssets;
    mapping(address => bool) internal collateralAssetKnown;
    address[] internal supportedCollateralAssets;

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    function initialize(
        address admin,
        address icft_,
        address priceOracle_,
        address riskEngine_,
        address interestRateModel_,
        uint256 fundAAllocation_,
        uint256 liquidityBuffer_
    ) external initializer {
        if (
            admin == address(0) ||
            icft_ == address(0) ||
            priceOracle_ == address(0) ||
            riskEngine_ == address(0) ||
            interestRateModel_ == address(0)
        ) revert InvalidAddress();
        if (fundAAllocation_ == 0) revert ZeroAmount();

        __AccessControl_init();
        __Pausable_init();
        __ReentrancyGuard_init();

        _grantRole(DEFAULT_ADMIN_ROLE, admin);
        _grantRole(PAUSER_ROLE, admin);
        _grantRole(CONFIG_ADMIN_ROLE, admin);
        _grantRole(LIQUIDATION_BOT_ROLE, admin);

        icft = IERC20(icft_);
        priceOracle = IPriceOracle(priceOracle_);
        riskEngine = IRiskEngine(riskEngine_);
        interestRateModel = IInterestRateModel(interestRateModel_);
        fundAAllocation = fundAAllocation_;
        liquidityBuffer = liquidityBuffer_;
        fundALiquidityICFT = fundAAllocation_;
        borrowIndex = INDEX_SCALE;
        lastAccrualTime = block.timestamp;

        _setCollateralAsset(NATIVE_ASSET, true, true);
    }

    function initializeCollateralRegistry() external reinitializer(2) onlyRole(CONFIG_ADMIN_ROLE) {
        if (!_isKnownCollateralAsset(NATIVE_ASSET)) {
            _setCollateralAsset(NATIVE_ASSET, true, true);
        }
    }

    receive() external payable {
        revert DirectETHTransfersDisabled();
    }

    function depositCollateral() external payable nonReentrant whenNotPaused {
        if (msg.value == 0) revert ZeroAmount();
        if (!collateralAssets[NATIVE_ASSET].enabled) revert UnsupportedCollateralAsset();

        Position storage position = positions[msg.sender];
        _syncPosition(position, msg.sender);

        position.collateralETH += msg.value;
        position.lastAccrualIndex = borrowIndex;
        position.active = true;

        emit DepositCollateral(msg.sender, NATIVE_ASSET, msg.value, position.collateralETH);
    }

    function depositCollateral(address asset, uint256 amount) external nonReentrant whenNotPaused {
        if (asset == NATIVE_ASSET) revert UnsupportedCollateralAsset();
        if (amount == 0) revert ZeroAmount();

        CollateralAsset memory collateralAsset = collateralAssets[asset];
        if (!collateralAsset.enabled || !collateralAssetKnown[asset]) revert UnsupportedCollateralAsset();

        Position storage position = positions[msg.sender];
        _syncPosition(position, msg.sender);

        IERC20(asset).safeTransferFrom(msg.sender, address(this), amount);
        erc20CollateralBalances[msg.sender][asset] += amount;
        position.lastAccrualIndex = borrowIndex;
        position.active = true;

        emit DepositCollateral(msg.sender, asset, amount, erc20CollateralBalances[msg.sender][asset]);
    }

    function withdrawCollateral(uint256 amountETH) external nonReentrant whenNotPaused {
        _withdrawCollateral(msg.sender, NATIVE_ASSET, amountETH);
    }

    function withdrawCollateral(address asset, uint256 amount) external nonReentrant whenNotPaused {
        if (asset == NATIVE_ASSET) revert UnsupportedCollateralAsset();
        _withdrawCollateral(msg.sender, asset, amount);
    }

    function borrow(uint256 amountICFT) external nonReentrant whenNotPaused {
        if (amountICFT == 0) revert ZeroAmount();

        Position storage position = positions[msg.sender];
        uint256 currentDebtUSD = _syncPosition(position, msg.sender);

        uint256 availableLiquidity = getAvailableLiquidity();
        if (amountICFT > availableLiquidity) revert InsufficientLiquidity();

        uint256 projectedUtilization = _calculateUtilizationAfterBorrow(amountICFT);
        if (projectedUtilization >= interestRateModel.getMaxBorrowUtilizationBps()) {
            revert BorrowingDisabledAtUtilization();
        }

        uint256 addedDebtUSD = priceOracle.convertICFTToUSD(amountICFT);
        uint256 newDebtUSD = currentDebtUSD + addedDebtUSD;
        uint256 collateralValueUSD = _getCollateralValueUSD(msg.sender, position);
        uint256 newLtv = riskEngine.calculateLTV(collateralValueUSD, newDebtUSD);
        if (newLtv > riskEngine.getMaxLTVBps()) revert BorrowExceedsLTV();

        uint256 scaledIncrease = _toScaledDebtRoundUp(addedDebtUSD, borrowIndex);
        position.principalDebtUSD += addedDebtUSD;
        position.scaledDebtUSD += scaledIncrease;
        position.lastAccrualIndex = borrowIndex;
        position.active = true;

        totalPrincipalDebtUSD += addedDebtUSD;
        totalScaledDebtUSD += scaledIncrease;
        fundALiquidityICFT -= amountICFT;
        totalBorrowedICFT += amountICFT;

        icft.safeTransfer(msg.sender, amountICFT);

        _emitFundAAccountingUpdate();
        emit Borrow(msg.sender, amountICFT, addedDebtUSD, newDebtUSD);
    }

    function repay(uint256 amountICFT) external nonReentrant {
        if (amountICFT == 0) revert ZeroAmount();

        Position storage position = positions[msg.sender];
        uint256 totalDebtUSD = _syncPosition(position, msg.sender);
        if (totalDebtUSD == 0) revert NoDebt();

        uint256 fullRepayICFT = priceOracle.convertUSDToICFT(totalDebtUSD, true);
        uint256 actualICFT = amountICFT < fullRepayICFT ? amountICFT : fullRepayICFT;
        uint256 repaidDebtUSD = actualICFT == fullRepayICFT ? totalDebtUSD : priceOracle.convertICFTToUSD(actualICFT);

        if (repaidDebtUSD == 0) revert NothingToRepay();

        uint256 currentInterestUSD = totalDebtUSD - position.principalDebtUSD;
        uint256 repaidInterestUSD = repaidDebtUSD < currentInterestUSD ? repaidDebtUSD : currentInterestUSD;
        uint256 repaidPrincipalUSD = repaidDebtUSD - repaidInterestUSD;
        if (repaidPrincipalUSD > position.principalDebtUSD) {
            repaidPrincipalUSD = position.principalDebtUSD;
        }

        (uint256 returnedPrincipalICFT, uint256 returnedRevenueICFT) =
            _splitReturnedICFT(actualICFT, repaidDebtUSD, repaidPrincipalUSD);

        icft.safeTransferFrom(msg.sender, address(this), actualICFT);

        _reduceDebt(position, totalDebtUSD, repaidDebtUSD, repaidPrincipalUSD, msg.sender);

        fundALiquidityICFT += returnedPrincipalICFT;
        protocolRevenueICFT += returnedRevenueICFT;
        totalBorrowedICFT = _saturatingSub(totalBorrowedICFT, returnedPrincipalICFT);

        _emitFundAAccountingUpdate();
        emit Repay(msg.sender, actualICFT, repaidDebtUSD, getDebt(msg.sender));
    }

    function liquidate(address user, address collateralAsset, uint256 maxICFTToRepay, address collateralRecipient)
        external
        nonReentrant
        whenNotPaused
        onlyRole(LIQUIDATION_BOT_ROLE)
    {
        if (collateralRecipient == address(0)) revert InvalidAddress();
        if (maxICFTToRepay == 0) revert ZeroAmount();

        Position storage position = positions[user];
        uint256 totalDebtUSD = _syncPosition(position, user);
        if (totalDebtUSD == 0) revert NoDebt();

        uint256 totalCollateralValueUSD = _getCollateralValueUSD(user, position);
        if (!riskEngine.isLiquidatable(totalCollateralValueUSD, totalDebtUSD)) revert NotLiquidatable();

        LiquidationSettlement memory settlement =
            _calculateLiquidationSettlement(user, collateralAsset, totalDebtUSD, totalCollateralValueUSD);
        uint256 requiredICFT = priceOracle.convertUSDToICFT(settlement.debtToCoverUSD, true);

        if (requiredICFT == 0 || settlement.collateralToSeizeAmount == 0) revert NotLiquidatable();
        if (requiredICFT > maxICFTToRepay) revert SlippageExceeded();

        DebtSettlement memory debtSettlement =
            _prepareDebtSettlement(position, totalDebtUSD, settlement.debtToCoverUSD, requiredICFT);

        icft.safeTransferFrom(msg.sender, address(this), requiredICFT);

        _reduceDebt(position, totalDebtUSD, settlement.debtToCoverUSD, debtSettlement.repaidPrincipalUSD, user);
        _decreaseCollateral(user, position, collateralAsset, settlement.collateralToSeizeAmount);

        fundALiquidityICFT += debtSettlement.returnedPrincipalICFT;
        protocolRevenueICFT += debtSettlement.returnedRevenueICFT;
        totalBorrowedICFT = _saturatingSub(totalBorrowedICFT, debtSettlement.returnedPrincipalICFT);

        _transferCollateral(collateralAsset, collateralRecipient, settlement.collateralToSeizeAmount);

        _emitFundAAccountingUpdate();
        emit Liquidation(
            user,
            msg.sender,
            collateralAsset,
            requiredICFT,
            settlement.debtToCoverUSD,
            settlement.collateralToSeizeAmount,
            settlement.collateralValueSeizedUSD,
            settlement.resultingLtvBps
        );
    }

    function pause() external onlyRole(PAUSER_ROLE) {
        _pause();
    }

    function unpause() external onlyRole(PAUSER_ROLE) {
        _unpause();
    }

    function setLiquidityBuffer(uint256 newLiquidityBuffer) external onlyRole(CONFIG_ADMIN_ROLE) {
        liquidityBuffer = newLiquidityBuffer;
        emit ParameterUpdated(keccak256("liquidityBuffer"), newLiquidityBuffer);
    }

    function setCollateralAsset(address asset, bool enabled) external onlyRole(CONFIG_ADMIN_ROLE) {
        if (asset != NATIVE_ASSET && enabled && !priceOracle.isCollateralAssetSupported(asset)) {
            revert UnsupportedCollateralAsset();
        }

        _setCollateralAsset(asset, enabled, asset == NATIVE_ASSET);
    }

    function accrueInterest() external {
        _accrueGlobalInterest();
    }

    function totalAccruedInterestUSD() public view returns (uint256) {
        uint256 totalDebtUSD = _debtFromScaled(totalScaledDebtUSD, _previewBorrowIndex());
        return totalDebtUSD > totalPrincipalDebtUSD ? totalDebtUSD - totalPrincipalDebtUSD : 0;
    }

    function getPosition(address user) external view returns (Position memory) {
        return positions[user];
    }

    function getDebt(address user) public view returns (uint256) {
        Position memory position = positions[user];
        return _debtFromScaled(position.scaledDebtUSD, _previewBorrowIndex());
    }

    function getCollateralBalance(address user, address asset) public view returns (uint256 balance) {
        if (asset == NATIVE_ASSET) {
            return positions[user].collateralETH;
        }

        return erc20CollateralBalances[user][asset];
    }

    function getSupportedCollateralAssets() external view returns (address[] memory assets) {
        return supportedCollateralAssets;
    }

    function getCollateralAsset(address asset) external view returns (CollateralAsset memory collateralAsset) {
        return collateralAssets[asset];
    }

    function getLTV(address user) external view returns (uint256 ltvBps) {
        return riskEngine.calculateLTV(_getCollateralValueUSD(user, positions[user]), getDebt(user));
    }

    function getUtilization() public view returns (uint256 utilizationBps) {
        return _calculateUtilization(totalBorrowedICFT);
    }

    function getCollateralValueUSD(address user) external view returns (uint256 collateralValueUSD) {
        return _getCollateralValueUSD(user, positions[user]);
    }

    function getCurrentInterest(address user) external view returns (uint256 accruedInterestUSD) {
        Position memory position = positions[user];
        uint256 totalDebtUSD = _debtFromScaled(position.scaledDebtUSD, _previewBorrowIndex());
        return totalDebtUSD > position.principalDebtUSD ? totalDebtUSD - position.principalDebtUSD : 0;
    }

    function getAvailableBorrow(address user) external view returns (uint256 availableBorrowICFT) {
        Position memory position = positions[user];
        uint256 debtUSD = _debtFromScaled(position.scaledDebtUSD, _previewBorrowIndex());
        uint256 maxBorrowUSD = riskEngine.getMaxBorrowUSD(_getCollateralValueUSD(user, position));

        if (maxBorrowUSD <= debtUSD) return 0;

        uint256 remainingBorrowUSD = maxBorrowUSD - debtUSD;
        uint256 remainingBorrowICFT = priceOracle.convertUSDToICFT(remainingBorrowUSD, false);
        uint256 availableLiquidity = getAvailableLiquidity();

        return remainingBorrowICFT < availableLiquidity ? remainingBorrowICFT : availableLiquidity;
    }

    function isLiquidatable(address user) external view returns (bool) {
        return riskEngine.isLiquidatable(
            _getCollateralValueUSD(user, positions[user]),
            _debtFromScaled(positions[user].scaledDebtUSD, _previewBorrowIndex())
        );
    }

    function getAvailableLiquidity() public view returns (uint256 availableLiquidityICFT) {
        uint256 spendablePrincipalBalance = getSpendablePrincipalBalance();
        uint256 principalInventory = fundALiquidityICFT < spendablePrincipalBalance ? fundALiquidityICFT : spendablePrincipalBalance;

        if (principalInventory <= liquidityBuffer) return 0;

        return principalInventory - liquidityBuffer;
    }

    function getSpendablePrincipalBalance() public view returns (uint256 spendablePrincipalICFT) {
        uint256 rawBalance = icft.balanceOf(address(this));
        return _saturatingSub(rawBalance, protocolRevenueICFT);
    }

    function _withdrawCollateral(address user, address asset, uint256 amount) internal {
        if (amount == 0) revert ZeroAmount();
        if (!_isKnownCollateralAsset(asset)) revert UnsupportedCollateralAsset();

        Position storage position = positions[user];
        uint256 currentDebtUSD = _syncPosition(position, user);
        uint256 currentBalance = _getCollateralBalanceStorage(user, position, asset);
        if (amount > currentBalance) revert InsufficientCollateral();

        uint256 currentCollateralValueUSD = _getCollateralValueUSD(user, position);
        uint256 withdrawnValueUSD = riskEngine.getCollateralValueUSD(asset, amount);
        uint256 remainingCollateralValueUSD =
            currentCollateralValueUSD > withdrawnValueUSD ? currentCollateralValueUSD - withdrawnValueUSD : 0;

        if (currentDebtUSD > 0) {
            uint256 resultingLtv = riskEngine.calculateLTV(remainingCollateralValueUSD, currentDebtUSD);
            if (resultingLtv > riskEngine.getMaxLTVBps()) revert BorrowExceedsLTV();
        }

        _decreaseCollateral(user, position, asset, amount);
        _transferCollateral(asset, user, amount);

        emit WithdrawCollateral(user, asset, amount, currentBalance - amount);
    }

    function _syncPosition(Position storage position, address user) internal returns (uint256 totalDebtUSD) {
        uint256 previousIndex = borrowIndex;
        uint256 debtBeforeUSD = _debtFromScaled(position.scaledDebtUSD, previousIndex);

        _accrueGlobalInterest();

        totalDebtUSD = _debtFromScaled(position.scaledDebtUSD, borrowIndex);
        if (totalDebtUSD > debtBeforeUSD && totalDebtUSD > position.principalDebtUSD) {
            emit InterestAccrued(user, totalDebtUSD - debtBeforeUSD, totalDebtUSD - position.principalDebtUSD);
        }

        position.lastAccrualIndex = borrowIndex;
    }

    function _accrueGlobalInterest() internal {
        uint256 previousAccrualTime = lastAccrualTime;
        if (block.timestamp <= previousAccrualTime) {
            return;
        }

        uint256 previousBorrowIndex = borrowIndex;
        lastAccrualTime = block.timestamp;

        if (totalScaledDebtUSD == 0 || totalBorrowedICFT == 0) {
            return;
        }

        uint256 elapsed = block.timestamp - previousAccrualTime;
        uint256 aprBps = interestRateModel.getBorrowRateBps(_calculateUtilization(totalBorrowedICFT));
        uint256 interestFactor = (previousBorrowIndex * aprBps * elapsed) / (BPS * YEAR);
        if (interestFactor == 0) {
            return;
        }

        borrowIndex = previousBorrowIndex + interestFactor;

        emit GlobalInterestAccrued(
            aprBps,
            previousBorrowIndex,
            borrowIndex,
            _debtFromScaled(totalScaledDebtUSD, borrowIndex),
            totalAccruedInterestUSD()
        );
    }

    function _reduceDebt(
        Position storage position,
        uint256 totalDebtUSD,
        uint256 repaidDebtUSD,
        uint256 repaidPrincipalUSD,
        address user
    ) internal {
        uint256 previousScaledDebtUSD = position.scaledDebtUSD;

        if (repaidDebtUSD >= totalDebtUSD) {
            totalScaledDebtUSD -= previousScaledDebtUSD;
            position.scaledDebtUSD = 0;
        } else {
            uint256 remainingDebtUSD = totalDebtUSD - repaidDebtUSD;
            uint256 newScaledDebtUSD = _toScaledDebtRoundUp(remainingDebtUSD, borrowIndex);

            if (newScaledDebtUSD >= previousScaledDebtUSD) {
                newScaledDebtUSD = previousScaledDebtUSD - 1;
            }

            totalScaledDebtUSD -= previousScaledDebtUSD - newScaledDebtUSD;
            position.scaledDebtUSD = newScaledDebtUSD;
        }

        if (repaidPrincipalUSD > 0) {
            position.principalDebtUSD -= repaidPrincipalUSD;
            totalPrincipalDebtUSD -= repaidPrincipalUSD;
        }

        position.lastAccrualIndex = borrowIndex;
        position.active = _hasAnyCollateral(user, position) || position.scaledDebtUSD > 0;
    }

    function _calculateLiquidationSettlement(
        address user,
        address collateralAsset,
        uint256 totalDebtUSD,
        uint256 totalCollateralValueUSD
    ) internal view returns (LiquidationSettlement memory settlement) {
        if (!_isKnownCollateralAsset(collateralAsset)) revert UnsupportedCollateralAsset();

        uint256 collateralBalance = getCollateralBalance(user, collateralAsset);
        if (collateralBalance == 0) return settlement;

        IRiskEngine.LiquidationOutcome memory outcome =
            riskEngine.calculateLiquidation(totalCollateralValueUSD, totalDebtUSD);
        if (outcome.debtToCoverUSD == 0 || outcome.collateralValueSeizedUSD == 0) {
            return settlement;
        }

        uint256 assetValueUSD = riskEngine.getCollateralValueUSD(collateralAsset, collateralBalance);
        uint256 desiredSeizedValueUSD =
            outcome.collateralValueSeizedUSD < assetValueUSD ? outcome.collateralValueSeizedUSD : assetValueUSD;

        uint256 seizeAmount = priceOracle.convertUSDToAsset(collateralAsset, desiredSeizedValueUSD, false);
        if (seizeAmount == 0 && desiredSeizedValueUSD > 0) {
            seizeAmount = 1;
        }
        if (seizeAmount > collateralBalance) {
            seizeAmount = collateralBalance;
        }

        uint256 actualSeizedValueUSD = riskEngine.getCollateralValueUSD(collateralAsset, seizeAmount);
        if (actualSeizedValueUSD > assetValueUSD) {
            actualSeizedValueUSD = assetValueUSD;
        }

        uint256 debtToCoverUSD = (actualSeizedValueUSD * BPS) / (BPS + riskEngine.getLiquidationBonusBps());
        if (debtToCoverUSD > totalDebtUSD) {
            debtToCoverUSD = totalDebtUSD;
        }

        uint256 remainingDebtUSD = totalDebtUSD > debtToCoverUSD ? totalDebtUSD - debtToCoverUSD : 0;
        uint256 remainingCollateralValueUSD =
            totalCollateralValueUSD > actualSeizedValueUSD ? totalCollateralValueUSD - actualSeizedValueUSD : 0;

        settlement = LiquidationSettlement({
            debtToCoverUSD: debtToCoverUSD,
            collateralToSeizeAmount: seizeAmount,
            collateralValueSeizedUSD: actualSeizedValueUSD,
            resultingLtvBps: riskEngine.calculateLTV(remainingCollateralValueUSD, remainingDebtUSD)
        });
    }

    function _prepareDebtSettlement(
        Position storage position,
        uint256 totalDebtUSD,
        uint256 repaidDebtUSD,
        uint256 returnedICFT
    ) internal view returns (DebtSettlement memory debtSettlement) {
        uint256 currentInterestUSD = totalDebtUSD - position.principalDebtUSD;
        uint256 repaidInterestUSD = repaidDebtUSD < currentInterestUSD ? repaidDebtUSD : currentInterestUSD;
        uint256 repaidPrincipalUSD = repaidDebtUSD - repaidInterestUSD;

        if (repaidPrincipalUSD > position.principalDebtUSD) {
            repaidPrincipalUSD = position.principalDebtUSD;
        }

        (uint256 returnedPrincipalICFT, uint256 returnedRevenueICFT) =
            _splitReturnedICFT(returnedICFT, repaidDebtUSD, repaidPrincipalUSD);

        debtSettlement = DebtSettlement({
            repaidPrincipalUSD: repaidPrincipalUSD,
            returnedPrincipalICFT: returnedPrincipalICFT,
            returnedRevenueICFT: returnedRevenueICFT
        });
    }

    function _getCollateralValueUSD(address user, Position memory position)
        internal
        view
        returns (uint256 collateralValueUSD)
    {
        uint256 assetsLength = supportedCollateralAssets.length;

        for (uint256 i = 0; i < assetsLength; ++i) {
            address asset = supportedCollateralAssets[i];
            uint256 balance = _getCollateralBalanceMemory(user, position, asset);

            if (balance == 0) {
                continue;
            }

            collateralValueUSD += riskEngine.getCollateralValueUSD(asset, balance);
        }
    }

    function _getCollateralBalanceMemory(address user, Position memory position, address asset)
        internal
        view
        returns (uint256 balance)
    {
        if (asset == NATIVE_ASSET) {
            return position.collateralETH;
        }

        return erc20CollateralBalances[user][asset];
    }

    function _getCollateralBalanceStorage(address user, Position storage position, address asset)
        internal
        view
        returns (uint256 balance)
    {
        if (asset == NATIVE_ASSET) {
            return position.collateralETH;
        }

        return erc20CollateralBalances[user][asset];
    }

    function _decreaseCollateral(address user, Position storage position, address asset, uint256 amount) internal {
        if (asset == NATIVE_ASSET) {
            position.collateralETH -= amount;
        } else {
            erc20CollateralBalances[user][asset] -= amount;
        }

        position.lastAccrualIndex = borrowIndex;
        position.active = _hasAnyCollateral(user, position) || position.scaledDebtUSD > 0;
    }

    function _transferCollateral(address asset, address recipient, uint256 amount) internal {
        if (asset == NATIVE_ASSET) {
            payable(recipient).sendValue(amount);
            return;
        }

        IERC20(asset).safeTransfer(recipient, amount);
    }

    function _setCollateralAsset(address asset, bool enabled, bool isNative) internal {
        if (!collateralAssetKnown[asset]) {
            collateralAssetKnown[asset] = true;
            supportedCollateralAssets.push(asset);
        }

        collateralAssets[asset] = CollateralAsset({enabled: enabled, isNative: isNative});
        emit CollateralAssetUpdated(asset, enabled, isNative);
    }

    function _isKnownCollateralAsset(address asset) internal view returns (bool known) {
        return collateralAssetKnown[asset];
    }

    function _hasAnyCollateral(address user, Position storage position) internal view returns (bool hasCollateral) {
        if (position.collateralETH > 0) {
            return true;
        }

        uint256 assetsLength = supportedCollateralAssets.length;
        for (uint256 i = 0; i < assetsLength; ++i) {
            address asset = supportedCollateralAssets[i];
            if (asset == NATIVE_ASSET) {
                continue;
            }

            if (erc20CollateralBalances[user][asset] > 0) {
                return true;
            }
        }

        return false;
    }

    function _calculateUtilizationAfterBorrow(uint256 amountICFT) internal view returns (uint256 utilizationBps) {
        return _calculateUtilization(totalBorrowedICFT + amountICFT);
    }

    function _calculateUtilization(uint256 borrowedICFT) internal view returns (uint256 utilizationBps) {
        return (borrowedICFT * BPS) / fundAAllocation;
    }

    function _splitReturnedICFT(uint256 totalReturnedICFT, uint256 repaidDebtUSD, uint256 repaidPrincipalUSD)
        internal
        pure
        returns (uint256 returnedPrincipalICFT, uint256 returnedRevenueICFT)
    {
        if (totalReturnedICFT == 0) {
            return (0, 0);
        }

        if (repaidPrincipalUSD == 0) {
            return (0, totalReturnedICFT);
        }

        if (repaidPrincipalUSD == repaidDebtUSD) {
            return (totalReturnedICFT, 0);
        }

        returnedPrincipalICFT = (totalReturnedICFT * repaidPrincipalUSD) / repaidDebtUSD;
        returnedRevenueICFT = totalReturnedICFT - returnedPrincipalICFT;
    }

    function _emitFundAAccountingUpdate() internal {
        emit FundAAccountingUpdated(
            fundALiquidityICFT,
            totalBorrowedICFT,
            totalPrincipalDebtUSD,
            totalAccruedInterestUSD(),
            protocolRevenueICFT
        );
    }

    function _debtFromScaled(uint256 scaledDebtUSD, uint256 index) internal pure returns (uint256 debtUSD) {
        return (scaledDebtUSD * index) / INDEX_SCALE;
    }

    function _toScaledDebtRoundUp(uint256 debtUSD, uint256 index) internal pure returns (uint256 scaledDebtUSD) {
        if (debtUSD == 0) {
            return 0;
        }

        scaledDebtUSD = (debtUSD * INDEX_SCALE) / index;
        if ((debtUSD * INDEX_SCALE) % index != 0) {
            scaledDebtUSD += 1;
        }
    }

    function _previewBorrowIndex() internal view returns (uint256 previewIndex) {
        previewIndex = borrowIndex;

        if (block.timestamp <= lastAccrualTime || totalScaledDebtUSD == 0 || totalBorrowedICFT == 0) {
            return previewIndex;
        }

        uint256 elapsed = block.timestamp - lastAccrualTime;
        uint256 aprBps = interestRateModel.getBorrowRateBps(_calculateUtilization(totalBorrowedICFT));
        previewIndex += (previewIndex * aprBps * elapsed) / (BPS * YEAR);
    }

    function _saturatingSub(uint256 a, uint256 b) internal pure returns (uint256 result) {
        return a > b ? a - b : 0;
    }
}
