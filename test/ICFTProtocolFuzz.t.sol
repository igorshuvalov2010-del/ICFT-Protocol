// SPDX-License-Identifier: GPL-3.0-only
pragma solidity ^0.8.20;

import {ProtocolFixture} from "./helpers/ProtocolFixture.sol";
import {LendingPool} from "../src/core/ICFT/lending/LendingPool.sol";
import {ILendingPool} from "../src/core/interfaces/ILendingPool.sol";
import {BorrowExceedsLTV} from "../src/core/utils/Errors.sol";

contract ICFTProtocolFuzzTest is ProtocolFixture {
    function setUp() public {
        _setUpProtocol();
    }

    function testFuzzBorrowDoesNotExceedMaxLtv(uint96 collateralEth, uint96 borrowIcft) public {
        uint256 collateral = bound(uint256(collateralEth), 1 ether, 100 ether);

        vm.prank(alice);
        lendingPool.depositCollateral{value: collateral}();

        uint256 maxBorrow = lendingPool.getAvailableBorrow(alice);
        uint256 amount = bound(uint256(borrowIcft), 1 ether, maxBorrow == 0 ? 1 ether : maxBorrow);

        if (amount > maxBorrow || maxBorrow == 0) return;

        vm.prank(alice);
        lendingPool.borrow(amount);

        assertLe(lendingPool.getLTV(alice), riskEngine.getMaxLTVBps());
        assertEq(lendingPool.totalBorrowedICFT(), amount);
    }

    function testFuzzPartialRepayNeverIncreasesDebt(uint96 collateralEth, uint96 borrowIcft, uint96 repayIcft) public {
        uint256 collateral = bound(uint256(collateralEth), 2 ether, 100 ether);

        vm.prank(alice);
        lendingPool.depositCollateral{value: collateral}();

        uint256 maxBorrow = lendingPool.getAvailableBorrow(alice);
        uint256 borrowAmount = bound(uint256(borrowIcft), 1 ether, maxBorrow == 0 ? 1 ether : maxBorrow);

        if (borrowAmount > maxBorrow || maxBorrow == 0) return;

        vm.prank(alice);
        lendingPool.borrow(borrowAmount);

        uint256 debtBefore = lendingPool.getDebt(alice);
        uint256 repayAmount = bound(uint256(repayIcft), 1, borrowAmount);

        vm.prank(alice);
        lendingPool.repay(repayAmount);

        uint256 debtAfter = lendingPool.getDebt(alice);
        assertLe(debtAfter, debtBefore);
    }

    function testFuzzWithdrawCannotBreakHealth(uint96 collateralEth, uint96 borrowIcft, uint96 withdrawEth) public {
        uint256 collateral = bound(uint256(collateralEth), 3 ether, 100 ether);

        vm.prank(alice);
        lendingPool.depositCollateral{value: collateral}();

        uint256 maxBorrow = lendingPool.getAvailableBorrow(alice);
        uint256 borrowAmount = bound(uint256(borrowIcft), 1 ether, maxBorrow == 0 ? 1 ether : maxBorrow);
        if (borrowAmount > maxBorrow || maxBorrow == 0) return;

        vm.prank(alice);
        lendingPool.borrow(borrowAmount);

        ILendingPool.Position memory position = lendingPool.getPosition(alice);
        if (position.collateralETH == 0) return;

        uint256 withdrawAmount = bound(uint256(withdrawEth), 1, position.collateralETH);
        uint256 debtBefore = lendingPool.getDebt(alice);

        if (debtBefore == 0) {
            vm.prank(alice);
            lendingPool.withdrawCollateral(withdrawAmount);
            return;
        }

        uint256 currentCollateralValueUsd = lendingPool.getCollateralValueUSD(alice);
        uint256 withdrawnValueUsd = riskEngine.getCollateralValueUSD(NATIVE_ASSET, withdrawAmount);
        uint256 resultingLtv = riskEngine.calculateLTV(currentCollateralValueUsd - withdrawnValueUsd, debtBefore);

        if (resultingLtv > riskEngine.getMaxLTVBps()) {
            vm.expectRevert(BorrowExceedsLTV.selector);
            vm.prank(alice);
            lendingPool.withdrawCollateral(withdrawAmount);
        } else {
            vm.prank(alice);
            lendingPool.withdrawCollateral(withdrawAmount);
            assertLe(lendingPool.getLTV(alice), riskEngine.getMaxLTVBps());
        }
    }
}
