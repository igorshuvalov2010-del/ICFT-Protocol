// SPDX-License-Identifier: GPL-3.0-only
pragma solidity ^0.8.20;

import {TransparentUpgradeableProxy} from "@openzeppelin/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";

import {ProtocolFixture} from "./helpers/ProtocolFixture.sol";
import {ICFT} from "../src/core/ICFT/token/ICFT.sol";
import {PriceOracle} from "../src/core/ICFT/oracle/PriceOracle.sol";
import {InterestRateModel} from "../src/core/ICFT/lending/InterestRateModel.sol";
import {LendingPool} from "../src/core/ICFT/lending/LendingPool.sol";
import {LiquidationEngine} from "../src/core/ICFT/lending/LiquidationEngine.sol";
import {RiskEngine} from "../src/core/ICFT/risk/RiskEngine.sol";
import {IInterestRateModel} from "../src/core/interfaces/IInterestRateModel.sol";
import {
    BorrowExceedsLTV,
    BorrowingDisabledAtUtilization,
    DirectETHTransfersDisabled,
    InsufficientCollateral,
    InsufficientLiquidity,
    InvalidAddress,
    NoDebt,
    ZeroAmount
} from "../src/core/utils/Errors.sol";

contract ICFTProtocolTest is ProtocolFixture {
    function _forwardEth(address payable target) external payable {
        (bool success, bytes memory returndata) = target.call{value: msg.value}("");
        if (!success) {
            assembly {
                revert(add(returndata, 0x20), mload(returndata))
            }
        }
    }

    function setUp() public {
        _setUpProtocol();
    }

    function testProxyInitializedCoreState() public view {
        assertEq(icft.totalSupply(), 1_000_000_000 ether);
        assertEq(lendingPool.fundALiquidityICFT(), FUND_A);
        assertEq(lendingPool.borrowIndex(), 1e18);
        assertEq(lendingPool.totalBorrowedICFT(), 0);
        assertEq(lendingPool.totalAccruedInterestUSD(), 0);
    }

    function testOracleNormalizesChainlinkAndManualPrices() public {
        assertEq(oracle.getETHUSDPrice(), 2_000e18);
        assertEq(oracle.getICFTUSDPrice(), 1e18);

        oracle.setManualICFTPrice(250_000_000, 8);
        assertEq(oracle.getICFTUSDPrice(), 2_500_000_000_000_000_000);
    }

    function testBorrowAndRepayUsesUsdDenominatedDebt() public {
        uint256 balanceBefore = icft.balanceOf(alice);

        vm.startPrank(alice);
        lendingPool.depositCollateral{value: 1 ether}();
        lendingPool.borrow(100 ether);
        vm.stopPrank();

        assertEq(lendingPool.getDebt(alice), 100e18);
        assertEq(lendingPool.totalBorrowedICFT(), 100 ether);
        assertEq(lendingPool.fundALiquidityICFT(), FUND_A - 100 ether);

        oracle.setManualICFTPrice(2e8, 8);

        vm.prank(alice);
        lendingPool.repay(50 ether);

        assertEq(lendingPool.getDebt(alice), 0);
        assertEq(icft.balanceOf(alice), balanceBefore + 50 ether);
        assertEq(lendingPool.totalBorrowedICFT(), 50 ether);
        assertEq(lendingPool.fundALiquidityICFT(), FUND_A - 50 ether);
        assertEq(lendingPool.protocolRevenueICFT(), 0);
    }

    function testAccrualUsesOldUtilizationBeforeNewBorrowChangesIt() public {
        vm.deal(alice, 30_000 ether);
        vm.deal(bob, 80_000 ether);

        vm.startPrank(alice);
        lendingPool.depositCollateral{value: 25_000 ether}();
        lendingPool.borrow(40_000_000 ether);
        vm.stopPrank();

        vm.warp(block.timestamp + 365 days);
        ethFeed.setRoundData(2_000e8, block.timestamp);

        vm.startPrank(bob);
        lendingPool.depositCollateral{value: 75_000 ether}();
        lendingPool.borrow(120_000_000 ether);
        vm.stopPrank();

        uint256 aliceDebt = lendingPool.getDebt(alice);
        assertEq(aliceDebt, 42_000_000 ether);
        assertEq(lendingPool.totalAccruedInterestUSD(), 2_000_000 ether);
        assertEq(lendingPool.borrowIndex(), 1_050_000_000_000_000_000);
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

    function testWbtcCollateralCanBeDepositedAndValued() public {
        uint256 depositAmount = 2 * 10 ** wbtc.decimals();

        vm.prank(alice);
        lendingPool.depositCollateral(address(wbtc), depositAmount);

        assertEq(lendingPool.getCollateralBalance(alice, address(wbtc)), depositAmount);
        assertEq(lendingPool.getCollateralValueUSD(alice), 120_000e18);
    }

    function testWstethCollateralCanBeDepositedAndValued() public {
        uint256 depositAmount = 5 ether;

        vm.prank(alice);
        lendingPool.depositCollateral(address(wsteth), depositAmount);

        assertEq(lendingPool.getCollateralBalance(alice, address(wsteth)), depositAmount);
        assertEq(lendingPool.getCollateralValueUSD(alice), 11_000e18);
    }

    function testBasketCollateralSupportsBorrowingAcrossEthAndWbtc() public {
        vm.startPrank(alice);
        lendingPool.depositCollateral{value: 1 ether}();
        lendingPool.depositCollateral(address(wbtc), 1 * 10 ** wbtc.decimals());
        lendingPool.borrow(45_000 ether);
        vm.stopPrank();

        assertEq(lendingPool.getDebt(alice), 45_000e18);
        assertEq(lendingPool.getCollateralValueUSD(alice), 62_000e18);
        assertLe(lendingPool.getLTV(alice), riskEngine.getMaxLTVBps());
    }

    function testBasketCollateralSupportsBorrowingAcrossEthWbtcAndWsteth() public {
        vm.startPrank(alice);
        lendingPool.depositCollateral{value: 1 ether}();
        lendingPool.depositCollateral(address(wbtc), 1 * 10 ** wbtc.decimals());
        lendingPool.depositCollateral(address(wsteth), 10 ether);
        lendingPool.borrow(60_000 ether);
        vm.stopPrank();

        assertEq(lendingPool.getDebt(alice), 60_000e18);
        assertEq(lendingPool.getCollateralValueUSD(alice), 84_000e18);
        assertLe(lendingPool.getLTV(alice), riskEngine.getMaxLTVBps());
    }

    function testPauseStopsBorrowButAllowsRepay() public {
        vm.prank(alice);
        lendingPool.depositCollateral{value: 1 ether}();

        lendingPool.pause();

        vm.prank(alice);
        vm.expectRevert();
        lendingPool.borrow(50 ether);

        lendingPool.unpause();

        vm.prank(alice);
        lendingPool.borrow(50 ether);

        lendingPool.pause();

        vm.prank(alice);
        lendingPool.repay(10 ether);

        assertLt(lendingPool.getDebt(alice), 50e18);
    }

    function testAccrueInterestWithNoDebtDoesNotChangeBorrowIndex() public {
        uint256 borrowIndexBefore = lendingPool.borrowIndex();
        uint256 lastAccrualBefore = lendingPool.lastAccrualTime();

        vm.warp(block.timestamp + 7 days);
        lendingPool.accrueInterest();

        assertEq(lendingPool.borrowIndex(), borrowIndexBefore);
        assertGt(lendingPool.lastAccrualTime(), lastAccrualBefore);
        assertEq(lendingPool.totalAccruedInterestUSD(), 0);
    }

    function testAccrueInterestWithZeroRateLeavesBorrowIndexUnchanged() public {
        IInterestRateModel.RateConfig memory zeroRateConfig = IInterestRateModel.RateConfig({
            kink1Bps: 5_000,
            kink2Bps: 8_000,
            kink3Bps: 9_000,
            rate1Bps: 0,
            rate2Bps: 0,
            rate3Bps: 0,
            rate4Bps: 0,
            maxBorrowUtilizationBps: 9_000
        });
        rateModel.setRateConfig(zeroRateConfig);

        vm.startPrank(alice);
        lendingPool.depositCollateral{value: 10 ether}();
        lendingPool.borrow(100 ether);
        vm.stopPrank();

        uint256 borrowIndexBefore = lendingPool.borrowIndex();
        vm.warp(block.timestamp + 30 days);
        lendingPool.accrueInterest();

        assertEq(lendingPool.borrowIndex(), borrowIndexBefore);
        assertEq(lendingPool.getDebt(alice), 100 ether);
        assertEq(lendingPool.totalAccruedInterestUSD(), 0);
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

        InterestRateModel rateImplementation = new InterestRateModel();
        LendingPool poolImplementation = new LendingPool();

        InterestRateModel smallRateModel = InterestRateModel(
            address(
                new TransparentUpgradeableProxy(
                    address(rateImplementation),
                    admin,
                    abi.encodeCall(InterestRateModel.initialize, (admin, config))
                )
            )
        );

        ICFT smallIcftImplementation = new ICFT();
        ICFT smallIcft = ICFT(
            address(
                new TransparentUpgradeableProxy(
                    address(smallIcftImplementation),
                    admin,
                    abi.encodeCall(ICFT.initialize, (admin, liquidity, reserve, futureInvestors, founder, developers, ecosystem))
                )
            )
        );

        LendingPool isolatedSmallPool = LendingPool(
            payable(
                address(
                    new TransparentUpgradeableProxy(
                        address(poolImplementation),
                        admin,
                        abi.encodeCall(
                            LendingPool.initialize,
                            (admin, address(smallIcft), address(oracle), address(riskEngine), address(smallRateModel), 1_000 ether, 0)
                        )
                    )
                )
            )
        );

        smallIcft.transfer(address(isolatedSmallPool), 1_000 ether);

        vm.deal(alice, 2 ether);
        vm.prank(alice);
        isolatedSmallPool.depositCollateral{value: 1 ether}();

        vm.prank(alice);
        vm.expectRevert(BorrowingDisabledAtUtilization.selector);
        isolatedSmallPool.borrow(900 ether);
    }

    function testAvailableLiquidityReturnsZeroWhenBufferConsumesInventory() public {
        lendingPool.setLiquidityBuffer(FUND_A);
        assertEq(lendingPool.getAvailableLiquidity(), 0);
    }

    function testGetAvailableBorrowIsCappedByPoolLiquidity() public {
        lendingPool.setLiquidityBuffer(FUND_A - 50 ether);

        vm.deal(alice, 100 ether);
        vm.prank(alice);
        lendingPool.depositCollateral{value: 100 ether}();

        assertEq(lendingPool.getAvailableBorrow(alice), 50 ether);
    }

    function testWithdrawRevertsWhenPositionWouldExceedMaxLtv() public {
        vm.startPrank(alice);
        lendingPool.depositCollateral{value: 1 ether}();
        lendingPool.borrow(1_500 ether);

        vm.expectRevert(BorrowExceedsLTV.selector);
        lendingPool.withdrawCollateral(0.4 ether);
        vm.stopPrank();
    }

    function testDirectEthTransfersRevert() public {
        vm.expectRevert(DirectETHTransfersDisabled.selector);
        this._forwardEth{value: 1 wei}(payable(address(lendingPool)));
    }

    function testRepayRevertsWithoutDebt() public {
        vm.prank(alice);
        vm.expectRevert(NoDebt.selector);
        lendingPool.repay(1 ether);
    }

    function testInterestOnlyRepayAccruesProtocolRevenueWithoutRestoringPrincipal() public {
        vm.startPrank(alice);
        lendingPool.depositCollateral{value: 1 ether}();
        lendingPool.borrow(100 ether);
        vm.stopPrank();

        vm.warp(block.timestamp + 365 days);
        ethFeed.setRoundData(2_000e8, block.timestamp);

        vm.prank(alice);
        lendingPool.repay(5 ether);

        assertEq(lendingPool.getDebt(alice), 100 ether);
        assertEq(lendingPool.protocolRevenueICFT(), 5 ether);
        assertEq(lendingPool.fundALiquidityICFT(), FUND_A - 100 ether);
        assertEq(lendingPool.totalBorrowedICFT(), 100 ether);
    }

    function testFullRepayAfterInterestSeparatesPrincipalAndRevenue() public {
        vm.startPrank(alice);
        lendingPool.depositCollateral{value: 1 ether}();
        lendingPool.borrow(100 ether);
        vm.stopPrank();

        vm.warp(block.timestamp + 365 days);
        ethFeed.setRoundData(2_000e8, block.timestamp);

        vm.prank(alice);
        lendingPool.repay(200 ether);

        assertEq(lendingPool.getDebt(alice), 0);
        assertEq(lendingPool.totalBorrowedICFT(), 0);
        assertEq(lendingPool.fundALiquidityICFT(), FUND_A);
        assertEq(lendingPool.protocolRevenueICFT(), 5 ether);
    }

    function testInitializersRejectZeroAdmin() public {
        PriceOracle oracleImplementation = new PriceOracle();

        vm.expectRevert();
        new TransparentUpgradeableProxy(
            address(oracleImplementation),
            admin,
            abi.encodeCall(PriceOracle.initialize, (address(0), address(ethFeed), 1 hours, 1e8, 8))
        );
    }
}
