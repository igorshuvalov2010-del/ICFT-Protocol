// SPDX-License-Identifier: GPL-3.0-only
pragma solidity ^0.8.20;

import {Test} from "forge-std/Test.sol";

import {ICFT} from "../../src/core/ICFT/token/ICFT.sol";
import {PriceOracle} from "../../src/core/ICFT/oracle/PriceOracle.sol";
import {InterestRateModel} from "../../src/core/ICFT/lending/InterestRateModel.sol";
import {IInterestRateModel} from "../../src/core/interfaces/IInterestRateModel.sol";
import {LendingPool} from "../../src/core/ICFT/lending/LendingPool.sol";
import {LiquidationEngine} from "../../src/core/ICFT/lending/LiquidationEngine.sol";
import {RiskEngine} from "../../src/core/ICFT/risk/RiskEngine.sol";
import {MockChainlinkFeed} from "../../src/mocks/MockChainlinkFeed.sol";

abstract contract ProtocolFixture is Test {
    uint256 internal constant ONE = 1e18;
    uint256 internal constant FUND_A = 200_000_000 ether;

    address internal admin = address(this);
    address internal liquidity = address(0x1001);
    address internal reserve = address(0x1002);
    address internal futureInvestors = address(0x1003);
    address internal founder = address(0x1004);
    address internal developers = address(0x1005);
    address internal ecosystem = address(0x1006);

    address internal alice = address(0x2001);
    address internal bob = address(0x2002);
    address internal carol = address(0x2003);
    address internal liquidator = address(0x3001);

    ICFT internal icft;
    MockChainlinkFeed internal ethFeed;
    PriceOracle internal oracle;
    InterestRateModel internal rateModel;
    RiskEngine internal riskEngine;
    LendingPool internal lendingPool;
    LiquidationEngine internal liquidationEngine;

    function _setUpProtocol() internal {
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

        icft = new ICFT(admin, liquidity, reserve, futureInvestors, founder, developers, ecosystem);
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

        vm.deal(alice, 1_000 ether);
        vm.deal(bob, 1_000 ether);
        vm.deal(carol, 1_000 ether);

        vm.startPrank(liquidity);
        icft.transfer(liquidator, 1_000_000 ether);
        icft.transfer(alice, 100_000 ether);
        icft.transfer(bob, 100_000 ether);
        icft.transfer(carol, 100_000 ether);
        vm.stopPrank();

        vm.prank(alice);
        icft.approve(address(lendingPool), type(uint256).max);
        vm.prank(bob);
        icft.approve(address(lendingPool), type(uint256).max);
        vm.prank(carol);
        icft.approve(address(lendingPool), type(uint256).max);
        vm.prank(liquidator);
        icft.approve(address(liquidationEngine), type(uint256).max);
    }
}
