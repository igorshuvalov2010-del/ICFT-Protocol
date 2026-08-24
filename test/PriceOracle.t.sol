// SPDX-License-Identifier: GPL-3.0-only
pragma solidity ^0.8.20;

import {ProtocolFixture} from "./helpers/ProtocolFixture.sol";
import {MockChainlinkFeed} from "../src/mocks/MockChainlinkFeed.sol";
import {PriceSource} from "../src/core/utils/PriceSource.sol";

contract PriceOracleTest is ProtocolFixture {
    function setUp() public {
        _setUpProtocol();
    }

    function testRevertsOnStaleEthOracle() public {
        vm.warp(3 hours);
        ethFeed.setRoundData(2_000e8, 1 hours);
        vm.expectRevert();
        oracle.getETHUSDPrice();
    }

    function testRevertsOnZeroEthOracleAnswer() public {
        ethFeed.setRoundData(0, block.timestamp);
        vm.expectRevert();
        oracle.getETHUSDPrice();
    }

    function testRevertsOnNegativeEthOracleAnswer() public {
        ethFeed.setRoundData(-1, block.timestamp);
        vm.expectRevert();
        oracle.getETHUSDPrice();
    }

    function testManualIcftPriceRejectsZero() public {
        vm.expectRevert();
        oracle.setManualICFTPrice(0, 8);
    }

    function testUnauthorizedManualIcftPriceUpdateReverts() public {
        vm.prank(alice);
        vm.expectRevert();
        oracle.setManualICFTPrice(2e8, 8);
    }

    function testNormalizePriceKeeps18DecimalsUntouched() public view {
        assertEq(oracle.normalizePrice(2e18, 18), 2e18);
    }

    function testNormalizePriceRejectsDecimalsAbove18() public {
        vm.expectRevert();
        oracle.normalizePrice(1, 19);
    }

    function testSetIcftUsdFeedRejectsZeroAddress() public {
        vm.expectRevert();
        oracle.setICFTUSDFeed(address(0));
    }

    function testSetIcftPriceSourceRejectsChainlinkWithoutFeed() public {
        vm.expectRevert();
        oracle.setICFTPriceSource(PriceSource.Chainlink);
    }

    function testChainlinkIcftSourcePathWorks() public {
        MockChainlinkFeed icftFeed = new MockChainlinkFeed(8, 15e7);
        oracle.setICFTUSDFeed(address(icftFeed));
        oracle.setICFTPriceSource(PriceSource.Chainlink);

        assertEq(oracle.getICFTUSDPrice(), 15e17);
    }

    function testSetMaxPriceAgeRejectsZero() public {
        vm.expectRevert();
        oracle.setMaxPriceAge(0);
    }

    function testConvertUsdToIcftSupportsRoundUpAndRoundDown() public view {
        uint256 roundDown = oracle.convertUSDToICFT(1e18, false);
        uint256 roundUp = oracle.convertUSDToICFT(1e18 + 1, true);

        assertEq(roundDown, 1e18);
        assertEq(roundUp, 1e18 + 1);
    }
}
