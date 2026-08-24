// SPDX-License-Identifier: GPL-3.0-only
pragma solidity ^0.8.20;

import {ProtocolFixture} from "./helpers/ProtocolFixture.sol";
import {InterestRateModel} from "../src/core/ICFT/lending/InterestRateModel.sol";
import {IInterestRateModel} from "../src/core/interfaces/IInterestRateModel.sol";
import {IRiskEngine} from "../src/core/interfaces/IRiskEngine.sol";

contract RiskAndRateModelTest is ProtocolFixture {
    function setUp() public {
        _setUpProtocol();
    }

    function testRateModelReturnsAllConfiguredBuckets() public view {
        assertEq(rateModel.getBorrowRateBps(4_999), 500);
        assertEq(rateModel.getBorrowRateBps(5_000), 800);
        assertEq(rateModel.getBorrowRateBps(8_000), 1_500);
        assertEq(rateModel.getBorrowRateBps(9_000), 2_000);
    }

    function testRateModelRejectsInvalidConfig() public {
        IInterestRateModel.RateConfig memory badConfig = IInterestRateModel.RateConfig({
            kink1Bps: 5_000,
            kink2Bps: 4_000,
            kink3Bps: 9_000,
            rate1Bps: 500,
            rate2Bps: 800,
            rate3Bps: 1_500,
            rate4Bps: 2_000,
            maxBorrowUtilizationBps: 9_000
        });

        vm.expectRevert();
        rateModel.setRateConfig(badConfig);
    }

    function testRiskEngineReturnsZeroLtvForZeroDebt() public view {
        assertEq(riskEngine.calculateLTV(1 ether, 0), 0);
    }

    function testRiskEngineReturnsMaxLtvForZeroCollateralWithDebt() public view {
        assertEq(riskEngine.calculateLTV(0, 1e18), type(uint256).max);
    }

    function testRiskEngineReturnsEmptyLiquidationForHealthyPosition() public view {
        uint256 healthyDebt = 1_000e18;
        uint256 collateral = 1 ether;

        assertFalse(riskEngine.isLiquidatable(collateral, healthyDebt));

        IRiskEngine.LiquidationOutcome memory outcome = riskEngine.calculateLiquidation(collateral, healthyDebt);

        assertEq(outcome.debtToCoverUSD, 0);
        assertEq(outcome.collateralToSeizeETH, 0);
        assertEq(outcome.collateralValueSeizedUSD, 0);
        assertEq(outcome.resultingLtvBps, 0);
    }

    function testRiskEngineRejectsInvalidParameters() public {
        vm.expectRevert();
        riskEngine.setRiskParameters(9_000, 8_000, 8_500, 500);
    }

    function testRiskEngineCanUpdateValidParameters() public {
        riskEngine.setRiskParameters(7_500, 8_800, 8_200, 300);

        assertEq(riskEngine.getMaxLTVBps(), 7_500);
        assertEq(riskEngine.getLiquidationThresholdBps(), 8_800);
        assertEq(riskEngine.getTargetLTVBps(), 8_200);
        assertEq(riskEngine.getLiquidationBonusBps(), 300);
    }
}
