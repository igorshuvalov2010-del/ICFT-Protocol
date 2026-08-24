// SPDX-License-Identifier: GPL-3.0-only
pragma solidity ^0.8.20;

import {Test} from "forge-std/Test.sol";

import {ICFT} from "../src/core/ICFT/token/ICFT.sol";
import {PriceOracle} from "../src/core/ICFT/oracle/PriceOracle.sol";
import {InterestRateModel} from "../src/core/ICFT/lending/InterestRateModel.sol";
import {IInterestRateModel} from "../src/core/interfaces/IInterestRateModel.sol";
import {LendingPool} from "../src/core/ICFT/lending/LendingPool.sol";
import {LiquidationEngine} from "../src/core/ICFT/lending/LiquidationEngine.sol";
import {RiskEngine} from "../src/core/ICFT/risk/RiskEngine.sol";
import {MockChainlinkFeed} from "../src/mocks/MockChainlinkFeed.sol";
import {
    BorrowExceedsLTV,
    BorrowingDisabledAtUtilization,
    DirectETHTransfersDisabled,
    InsufficientCollateral,
    InsufficientLiquidity,
    InvalidAddress,
    MaxRepayBelowRequired,
    NoDebt,
    NotLiquidatable,
    ZeroAmount
} from "../src/core/utils/Errors.sol";

contract ICFTProtocolTest is Test {
    uint256 internal constant ONE = 1e18;
    uint256 internal constant FUND_A = 200_000_000 ether;

    address internal admin = address(this);
    address internal liquidity = makeAddr("liquidity");
    address internal reserve = makeAddr("reserve");
    address internal futureInvestors = makeAddr("futureInvestors");
    address internal founder = makeAddr("founder");
    address internal developers = makeAddr("developers");
    address internal ecosystem = makeAddr("ecosystem");

    address internal alice = makeAddr("alice");
    address internal liquidator = makeAddr("liquidator");

    ICFT internal icft;
    MockChainlinkFeed internal ethFeed;
    PriceOracle internal oracle;
    InterestRateModel internal rateModel;
    RiskEngine internal riskEngine;
    LendingPool internal lendingPool;
    LiquidationEngine internal liquidationEngine;

    function setUp() public {
        ethFeed = new MockChainlinkFeed(8, 2_000e8);

        oracle = new PriceOracle(admin, address(ethFeed), 1 hours, 1e8, 8);

        IInterestRateModel.RateConfig memory config = IInterestRateModel.RateConfig({
            kink1Bps: 5_000,
            kink2Bps: 8_000,
            kink3Bps: 9_000,
            rate1Bps: 500,
            rate2Bps: 800,
            rate3Bps: 1_500,
            rate4Bps: 2_000,
            maxBorrowUtilizationBps: 9_000
        });
        rateModel = new InterestRateModel(admin, config);

        riskEngine = new RiskEngine(admin, address(oracle), 8_000, 9_000, 8_500, 500);

        icft = new ICFT(
            admin,
            liquidity,
            reserve,
            futureInvestors,
            founder,
            developers,
            ecosystem
        );

        lendingPool = new LendingPool(
            admin,
            address(icft),
            address(oracle),
            address(riskEngine),
            address(rateModel),
            FUND_A,
            1_000 ether
        );

        liquidationEngine = new LiquidationEngine(admin, address(icft), address(lendingPool));

        icft.transfer(address(lendingPool), FUND_A);
        lendingPool.grantRole(lendingPool.LIQUIDATION_BOT_ROLE(), address(liquidationEngine));
        liquidationEngine.grantRole(liquidationEngine.OPERATOR_ROLE(), liquidator);

        vm.deal(alice, 10 ether);
        vm.prank(liquidity);
        icft.transfer(liquidator, 10_000 ether);

        assertEq(lendingPool.fundALiquidityICFT(), FUND_A);
        assertEq(lendingPool.totalBorrowedICFT(), 0);
        assertEq(lendingPool.protocolRevenueICFT(), 0);
    }

    function testOracleNormalizesChainlinkAndManualPrices() public {
        assertEq(oracle.getETHUSDPrice(), 2_000e18);
        assertEq(oracle.getICFTUSDPrice(), 1e18);

        oracle.setManualICFTPrice(250_000_000, 8);
        assertEq(oracle.getICFTUSDPrice(), 2_500_000_000_000_000_000);
    }

    function testBorrowAndRepayUsesUsdDenominatedDebt() public {
        vm.startPrank(alice);
        lendingPool.depositCollateral{value: 1 ether}();
        lendingPool.borrow(100 ether);
        icft.approve(address(lendingPool), type(uint256).max);
        vm.stopPrank();

        assertEq(lendingPool.getDebt(alice), 100e18);
        assertEq(lendingPool.totalBorrowedICFT(), 100 ether);
        assertEq(lendingPool.fundALiquidityICFT(), FUND_A - 100 ether);

        oracle.setManualICFTPrice(2e8, 8);

        vm.startPrank(alice);
        lendingPool.repay(50 ether);
        vm.stopPrank();

        assertEq(lendingPool.getDebt(alice), 0);
        assertEq(icft.balanceOf(alice), 50 ether);
        assertEq(lendingPool.totalBorrowedICFT(), 50 ether);
        assertEq(lendingPool.fundALiquidityICFT(), FUND_A - 50 ether);
        assertEq(lendingPool.protocolRevenueICFT(), 0);
    }

    function testConstructorRejectsZeroAdmin() public {
        vm.expectRevert(InvalidAddress.selector);
        new LendingPool(
            address(0),
            address(icft),
            address(oracle),
            address(riskEngine),
            address(rateModel),
            FUND_A,
            1_000 ether
        );
    }

    function testConstructorRejectsZeroFundAAllocation() public {
        vm.expectRevert(ZeroAmount.selector);
        new LendingPool(
            admin,
            address(icft),
            address(oracle),
            address(riskEngine),
            address(rateModel),
            0,
            1_000 ether
        );
    }

    function testWithdrawRevertsWhenPositionWouldExceedMaxLtv() public {
        vm.startPrank(alice);
        lendingPool.depositCollateral{value: 1 ether}();
        lendingPool.borrow(1_500 ether);

        vm.expectRevert(BorrowExceedsLTV.selector);
        lendingPool.withdrawCollateral(0.4 ether);
        vm.stopPrank();
    }

    function testDepositCollateralRejectsZeroAmount() public {
        vm.expectRevert(ZeroAmount.selector);
        lendingPool.depositCollateral{value: 0}();
    }

    function testWithdrawRejectsZeroAmount() public {
        vm.expectRevert(ZeroAmount.selector);
        lendingPool.withdrawCollateral(0);
    }

    function testWithdrawRejectsInsufficientCollateral() public {
        vm.prank(alice);
        vm.expectRevert(InsufficientCollateral.selector);
        lendingPool.withdrawCollateral(1 wei);
    }

    function testWithdrawAllCollateralWhenDebtIsZero() public {
        vm.prank(alice);
        lendingPool.depositCollateral{value: 1 ether}();

        vm.prank(alice);
        lendingPool.withdrawCollateral(1 ether);

        assertEq(lendingPool.getDebt(alice), 0);
        assertEq(lendingPool.getLTV(alice), 0);
    }

    function testPauseStopsBorrowButAllowsRepay() public {
        vm.startPrank(alice);
        lendingPool.depositCollateral{value: 1 ether}();
        vm.stopPrank();

        lendingPool.pause();

        vm.prank(alice);
        vm.expectRevert();
        lendingPool.borrow(50 ether);

        lendingPool.unpause();

        vm.startPrank(alice);
        lendingPool.borrow(50 ether);
        icft.approve(address(lendingPool), type(uint256).max);
        vm.stopPrank();

        lendingPool.pause();

        vm.prank(alice);
        lendingPool.repay(10 ether);

        assertLt(lendingPool.getDebt(alice), 50e18);
    }

    function testBorrowRejectsZeroAmount() public {
        vm.expectRevert(ZeroAmount.selector);
        lendingPool.borrow(0);
    }

    function testBorrowRejectsInsufficientLiquidity() public {
        vm.deal(alice, 2_000 ether);
        vm.prank(alice);
        lendingPool.depositCollateral{value: 1_000 ether}();

        vm.prank(alice);
        vm.expectRevert(InsufficientLiquidity.selector);
        lendingPool.borrow(FUND_A);
    }

    function testBorrowRejectsAtUtilizationCap() public {
        uint256 smallFundA = 1_000 ether;
        LendingPool smallPool = new LendingPool(
            admin,
            address(icft),
            address(oracle),
            address(riskEngine),
            address(rateModel),
            smallFundA,
            0
        );
        vm.prank(liquidity);
        icft.transfer(address(smallPool), smallFundA);

        vm.deal(alice, 2 ether);
        vm.prank(alice);
        smallPool.depositCollateral{value: 1 ether}();

        vm.prank(alice);
        vm.expectRevert(BorrowingDisabledAtUtilization.selector);
        smallPool.borrow(900 ether);
    }

    function testBorrowRejectsWhenLtvExceeded() public {
        vm.prank(alice);
        lendingPool.depositCollateral{value: 1 ether}();

        vm.prank(alice);
        vm.expectRevert(BorrowExceedsLTV.selector);
        lendingPool.borrow(1_700 ether);
    }

    function testInterestCreatesProtocolRevenueBucket() public {
        vm.startPrank(alice);
        lendingPool.depositCollateral{value: 1 ether}();
        lendingPool.borrow(100 ether);
        icft.approve(address(lendingPool), type(uint256).max);
        vm.stopPrank();

        vm.warp(block.timestamp + 365 days);

        vm.prank(alice);
        lendingPool.repay(10 ether);

        assertGt(lendingPool.protocolRevenueICFT(), 0);
        assertEq(lendingPool.totalBorrowedICFT(), 95 ether);
        assertEq(lendingPool.fundALiquidityICFT(), FUND_A - 95 ether);
        assertEq(lendingPool.totalAccruedInterestUSD(), 0);
        assertEq(lendingPool.totalPrincipalDebtUSD(), 95 ether);
    }

    function testAvailableLiquidityUsesFundABucketNotRawBalance() public {
        vm.startPrank(alice);
        lendingPool.depositCollateral{value: 1 ether}();
        lendingPool.borrow(100 ether);
        icft.approve(address(lendingPool), type(uint256).max);
        vm.stopPrank();

        oracle.setManualICFTPrice(2e8, 8);

        vm.prank(alice);
        lendingPool.repay(50 ether);

        assertEq(lendingPool.getAvailableLiquidity(), FUND_A - 50 ether - 1_000 ether);
        assertEq(lendingPool.getSpendablePrincipalBalance(), FUND_A - 50 ether);
    }

    function testAvailableLiquidityReturnsZeroWhenBufferExhaustsInventory() public {
        lendingPool.setLiquidityBuffer(FUND_A);
        assertEq(lendingPool.getAvailableLiquidity(), 0);
    }

    function testAvailableBorrowReturnsZeroWhenPositionAlreadyAtLimit() public {
        vm.startPrank(alice);
        lendingPool.depositCollateral{value: 1 ether}();
        lendingPool.borrow(1_600 ether);
        vm.stopPrank();

        assertEq(lendingPool.getAvailableBorrow(alice), 0);
    }

    function testRepayRejectsZeroAmount() public {
        vm.expectRevert(ZeroAmount.selector);
        lendingPool.repay(0);
    }

    function testRepayRejectsWhenNoDebt() public {
        vm.prank(alice);
        vm.expectRevert(NoDebt.selector);
        lendingPool.repay(1 ether);
    }

    function testRepayUsesFullRepayPathWhenAmountExceedsDebt() public {
        vm.startPrank(alice);
        lendingPool.depositCollateral{value: 1 ether}();
        lendingPool.borrow(100 ether);
        icft.approve(address(lendingPool), type(uint256).max);
        lendingPool.repay(200 ether);
        vm.stopPrank();

        assertEq(lendingPool.getDebt(alice), 0);
        assertEq(lendingPool.totalPrincipalDebtUSD(), 0);
    }

    function testLiquidationReducesDebtAndSeizesCollateral() public {
        vm.startPrank(alice);
        lendingPool.depositCollateral{value: 1 ether}();
        lendingPool.borrow(160 ether);
        vm.stopPrank();

        ethFeed.setRoundData(170e8, block.timestamp);

        uint256 collateralBefore = liquidator.balance;

        vm.startPrank(liquidator);
        icft.approve(address(lendingPool), type(uint256).max);
        icft.approve(address(liquidationEngine), type(uint256).max);
        liquidationEngine.executeLiquidation(alice, type(uint256).max, payable(liquidator));
        vm.stopPrank();

        assertLt(lendingPool.getDebt(alice), 160e18);
        assertGt(liquidator.balance, collateralBefore);
        assertLe(lendingPool.getLTV(alice), 8_500);
        assertGt(lendingPool.fundALiquidityICFT(), FUND_A - 160 ether);
        assertEq(liquidationEngine.totalExecutions(), 1);
        assertGt(liquidationEngine.totalRepaidIcft(), 0);
        assertGt(liquidationEngine.totalRepaidUsd(), 0);
        assertGt(liquidationEngine.totalSeizedEth(), 0);
    }

    function testPoolLiquidationRejectsZeroBeneficiary() public {
        vm.prank(address(liquidationEngine));
        vm.expectRevert(InvalidAddress.selector);
        lendingPool.liquidate(alice, 1 ether, address(0));
    }

    function testPoolLiquidationRejectsWhenNoDebt() public {
        lendingPool.grantRole(lendingPool.LIQUIDATION_BOT_ROLE(), address(this));
        vm.expectRevert(NoDebt.selector);
        lendingPool.liquidate(alice, 1 ether, address(this));
    }

    function testPoolLiquidationRejectsHealthyPosition() public {
        lendingPool.grantRole(lendingPool.LIQUIDATION_BOT_ROLE(), address(this));

        vm.startPrank(alice);
        lendingPool.depositCollateral{value: 1 ether}();
        lendingPool.borrow(100 ether);
        vm.stopPrank();

        vm.expectRevert(NotLiquidatable.selector);
        lendingPool.liquidate(alice, 100 ether, address(this));
    }

    function testPoolLiquidationRejectsWhenPaused() public {
        vm.startPrank(alice);
        lendingPool.depositCollateral{value: 1 ether}();
        lendingPool.borrow(160 ether);
        vm.stopPrank();

        ethFeed.setRoundData(170e8, block.timestamp);
        lendingPool.pause();

        vm.prank(liquidator);
        vm.expectRevert();
        liquidationEngine.executeLiquidation(alice, type(uint256).max, payable(liquidator));
    }

    function testLiquidationPreviewExposesSettlementPlan() public {
        vm.startPrank(alice);
        lendingPool.depositCollateral{value: 1 ether}();
        lendingPool.borrow(160 ether);
        vm.stopPrank();

        ethFeed.setRoundData(170e8, block.timestamp);

        LiquidationEngine.LiquidationPreview memory preview = liquidationEngine.previewLiquidation(alice);

        assertTrue(preview.isLiquidatable);
        assertGt(preview.requiredIcft, 0);
        assertGt(preview.collateralToSeizeEth, 0);
        assertLe(preview.resultingLtvBps, 8_500);
    }

    function testDirectEthTransferReverts() public {
        vm.deal(address(this), 1 ether);
        vm.expectRevert(DirectETHTransfersDisabled.selector);
        payable(address(lendingPool)).transfer(1 ether);
    }

    function testLiquidationEngineRejectsZeroBeneficiary() public {
        vm.prank(liquidator);
        vm.expectRevert();
        liquidationEngine.executeLiquidation(alice, 1 ether, payable(address(0)));
    }

    function testLiquidationEngineRejectsZeroMaxRepay() public {
        vm.prank(liquidator);
        vm.expectRevert();
        liquidationEngine.executeLiquidation(alice, 0, payable(liquidator));
    }

    function testLiquidationEnginePreviewReturnsEmptyForHealthyPosition() public {
        vm.prank(alice);
        lendingPool.depositCollateral{value: 1 ether}();

        LiquidationEngine.LiquidationPreview memory preview = liquidationEngine.previewLiquidation(alice);
        assertFalse(preview.isLiquidatable);
        assertEq(preview.requiredIcft, 0);
        assertEq(preview.collateralToSeizeEth, 0);
    }

    function testLiquidationEngineRejectsUnauthorizedOperator() public {
        vm.prank(alice);
        vm.expectRevert();
        liquidationEngine.executeLiquidation(alice, 1 ether, payable(alice));
    }

    function testLiquidationEngineHonorsMaxRepayLimit() public {
        vm.startPrank(alice);
        lendingPool.depositCollateral{value: 1 ether}();
        lendingPool.borrow(160 ether);
        vm.stopPrank();

        ethFeed.setRoundData(170e8, block.timestamp);

        LiquidationEngine.LiquidationPreview memory preview = liquidationEngine.previewLiquidation(alice);
        uint256 limitedMax = preview.requiredIcft - 1;

        vm.prank(liquidator);
        vm.expectRevert(MaxRepayBelowRequired.selector);
        liquidationEngine.executeLiquidation(alice, limitedMax, payable(liquidator));
    }

    function testSetLiquidityBufferUpdatesValue() public {
        lendingPool.setLiquidityBuffer(123 ether);
        assertEq(lendingPool.liquidityBuffer(), 123 ether);
    }

    function testCurrentInterestIsZeroWithoutDebt() public view {
        assertEq(lendingPool.getCurrentInterest(alice), 0);
    }

    function testGetSpendablePrincipalBalanceSubtractsRevenue() public {
        vm.startPrank(alice);
        lendingPool.depositCollateral{value: 1 ether}();
        lendingPool.borrow(100 ether);
        icft.approve(address(lendingPool), type(uint256).max);
        vm.stopPrank();

        vm.warp(block.timestamp + 365 days);

        vm.prank(alice);
        lendingPool.repay(10 ether);

        assertEq(
            lendingPool.getSpendablePrincipalBalance(),
            icft.balanceOf(address(lendingPool)) - lendingPool.protocolRevenueICFT()
        );
    }
}
