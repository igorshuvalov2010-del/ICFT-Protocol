// SPDX-License-Identifier: GPL-3.0-only
pragma solidity ^0.8.20;

import {TransparentUpgradeableProxy} from "@openzeppelin/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";
import {ProxyAdmin} from "@openzeppelin/contracts/proxy/transparent/ProxyAdmin.sol";
import {ITransparentUpgradeableProxy} from "@openzeppelin/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";

import {ProtocolFixture} from "./helpers/ProtocolFixture.sol";
import {ILiquidationEngine} from "../src/core/interfaces/ILiquidationEngine.sol";
import {PriceOracle} from "../src/core/ICFT/oracle/PriceOracle.sol";
import {PriceOracleV2Mock} from "../src/mocks/PriceOracleV2Mock.sol";
import {
    EthTransferFailed,
    InvalidAddress,
    InvalidAmount,
    MaxRepayBelowRequired,
    NoDebt,
    NotLiquidatable
} from "../src/core/utils/Errors.sol";

contract LiquidationAndUpgradeabilityTest is ProtocolFixture {
    bytes32 internal constant ERC1967_ADMIN_SLOT =
        0xb53127684a568b3173ae13b9f8a6016e243e63b6e8ee1178d6a717850b5d6103;
    function setUp() public {
        _setUpProtocol();
    }

    function testPreviewLiquidationReturnsEmptyForHealthyPosition() public {
        vm.prank(alice);
        lendingPool.depositCollateral{value: 1 ether}();

        ILiquidationEngine.LiquidationPreview memory preview = liquidationEngine.previewLiquidation(alice, NATIVE_ASSET);

        assertFalse(preview.isLiquidatable);
        assertEq(preview.debtUsd, 0);
        assertEq(preview.requiredIcft, 0);
        assertEq(preview.collateralToSeizeAmount, 0);
    }

    function testPreviewLiquidationReturnsComputedSliceForUnhealthyPosition() public {
        _openLiquidatableAlicePosition();

        ILiquidationEngine.LiquidationPreview memory preview = liquidationEngine.previewLiquidation(alice, NATIVE_ASSET);

        assertTrue(preview.isLiquidatable);
        assertGt(preview.debtUsd, 0);
        assertGt(preview.requiredIcft, 0);
        assertGt(preview.collateralToSeizeAmount, 0);
        assertLt(preview.resultingLtvBps, 9_000);
    }

    function testExecuteLiquidationRevertsForUnauthorizedOperator() public {
        _openLiquidatableAlicePosition();

        vm.prank(alice);
        vm.expectRevert();
        liquidationEngine.executeLiquidation(alice, NATIVE_ASSET, 1 ether, payable(alice));
    }

    function testExecuteLiquidationRevertsForZeroBeneficiary() public {
        _openLiquidatableAlicePosition();

        vm.prank(liquidator);
        vm.expectRevert(InvalidAddress.selector);
        liquidationEngine.executeLiquidation(alice, NATIVE_ASSET, 1 ether, payable(address(0)));
    }

    function testExecuteLiquidationRevertsForZeroMaxRepay() public {
        _openLiquidatableAlicePosition();

        vm.prank(liquidator);
        vm.expectRevert(InvalidAmount.selector);
        liquidationEngine.executeLiquidation(alice, NATIVE_ASSET, 0, payable(liquidator));
    }

    function testExecuteLiquidationRevertsWhenMaxRepayBelowRequired() public {
        _openLiquidatableAlicePosition();

        ILiquidationEngine.LiquidationPreview memory preview = liquidationEngine.previewLiquidation(alice, NATIVE_ASSET);

        vm.prank(liquidator);
        vm.expectRevert(MaxRepayBelowRequired.selector);
        liquidationEngine.executeLiquidation(alice, NATIVE_ASSET, preview.requiredIcft - 1, payable(liquidator));
    }

    function testExecuteLiquidationRevertsForHealthyPosition() public {
        vm.prank(alice);
        lendingPool.depositCollateral{value: 1 ether}();

        vm.prank(liquidator);
        vm.expectRevert(NoDebt.selector);
        liquidationEngine.executeLiquidation(alice, NATIVE_ASSET, 1 ether, payable(liquidator));
    }

    function testExecuteLiquidationRevertsForNotLiquidatablePosition() public {
        vm.startPrank(alice);
        lendingPool.depositCollateral{value: 1 ether}();
        lendingPool.borrow(1_000 ether);
        vm.stopPrank();

        vm.prank(liquidator);
        vm.expectRevert(NotLiquidatable.selector);
        liquidationEngine.executeLiquidation(alice, NATIVE_ASSET, 1_000 ether, payable(liquidator));
    }

    function testExecuteLiquidationTransfersEthAndUpdatesEngineStats() public {
        _openLiquidatableAlicePosition();

        ILiquidationEngine.LiquidationPreview memory preview = liquidationEngine.previewLiquidation(alice, NATIVE_ASSET);
        uint256 beneficiaryEthBefore = liquidator.balance;
        uint256 debtBefore = lendingPool.getDebt(alice);

        vm.prank(liquidator);
        (uint256 repaidIcft, uint256 repaidUsd, uint256 seizedEth) =
            liquidationEngine.executeLiquidation(alice, NATIVE_ASSET, preview.requiredIcft, payable(liquidator));

        uint256 debtAfter = lendingPool.getDebt(alice);

        assertEq(repaidIcft, preview.requiredIcft);
        assertEq(repaidUsd, debtBefore - debtAfter);
        assertEq(seizedEth, preview.collateralToSeizeAmount);
        assertEq(liquidator.balance, beneficiaryEthBefore + seizedEth);
        assertEq(liquidationEngine.totalExecutions(), 1);
        assertEq(liquidationEngine.totalRepaidIcft(), repaidIcft);
        assertEq(liquidationEngine.totalRepaidUsd(), repaidUsd);
        assertEq(liquidationEngine.totalSeizedByAsset(NATIVE_ASSET), seizedEth);
        assertEq(liquidationEngine.previewResultingLtv(alice), lendingPool.getLTV(alice));
    }

    function testRecoverNativeRevertsForUnauthorizedCaller() public {
        vm.deal(address(liquidationEngine), 1 ether);

        vm.prank(alice);
        vm.expectRevert();
        liquidationEngine.recoverNative(payable(alice), 1 ether);
    }

    function testRecoverNativeTransfersAccidentallyReceivedEth() public {
        vm.deal(address(liquidationEngine), 1 ether);
        uint256 recipientBalanceBefore = alice.balance;

        liquidationEngine.recoverNative(payable(alice), 0.4 ether);

        assertEq(address(liquidationEngine).balance, 0.6 ether);
        assertEq(alice.balance, recipientBalanceBefore + 0.4 ether);
    }

    function testRecoverNativeRevertsWhenTransferFails() public {
        vm.deal(address(liquidationEngine), 1 ether);
        RejectEther receiver = new RejectEther();

        vm.expectRevert(EthTransferFailed.selector);
        liquidationEngine.recoverNative(payable(address(receiver)), 0.2 ether);
    }

    function testProxyAdminSlotPointsToOwnedProxyAdmin() public view {
        address proxyAdmin = address(uint160(uint256(vm.load(address(oracle), ERC1967_ADMIN_SLOT))));

        assertTrue(proxyAdmin.code.length > 0);
        assertEq(ProxyAdmin(proxyAdmin).owner(), upgradeAdmin);
    }

    function testPriceOracleProxyCanUpgradeToV2Implementation() public {
        address proxyAdminAddress = address(uint160(uint256(vm.load(address(oracle), ERC1967_ADMIN_SLOT))));
        PriceOracleV2Mock upgradedImplementation = new PriceOracleV2Mock();

        ProxyAdmin(proxyAdminAddress).upgradeAndCall(
            ITransparentUpgradeableProxy(payable(address(oracle))), address(upgradedImplementation), ""
        );

        assertEq(PriceOracleV2Mock(address(oracle)).versionMarker(), 2);
        assertEq(oracle.getETHUSDPrice(), 2_000e18);
        assertEq(oracle.getICFTUSDPrice(), 1e18);
    }

    function testPriceOracleProxyRejectsDirectInitializeAfterDeployment() public {
        vm.expectRevert();
        oracle.initialize(admin, address(ethFeed), 1 hours, 1e8, 8);
    }

    function testLiquidationEngineProxyRejectsDirectInitializeAfterDeployment() public {
        vm.expectRevert();
        liquidationEngine.initialize(admin, address(icft), address(lendingPool));
    }

    function _openLiquidatableAlicePosition() internal {
        vm.startPrank(alice);
        lendingPool.depositCollateral{value: 1 ether}();
        lendingPool.borrow(1_500 ether);
        vm.stopPrank();

        ethFeed.setRoundData(1_600e8, block.timestamp);
    }
}

contract RejectEther {
    receive() external payable {
        revert("no eth");
    }
}
