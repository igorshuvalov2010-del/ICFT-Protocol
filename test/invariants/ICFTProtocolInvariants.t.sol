// SPDX-License-Identifier: GPL-3.0-only
pragma solidity ^0.8.20;

import {StdInvariant} from "forge-std/StdInvariant.sol";
import {Test} from "forge-std/Test.sol";

import {ProtocolFixture} from "../helpers/ProtocolFixture.sol";
import {LendingPool} from "../../src/core/ICFT/lending/LendingPool.sol";

contract ProtocolHandler is Test {
    LendingPool internal lendingPool;
    address[] internal actors;

    address internal alice;
    address internal bob;
    address internal carol;
    address internal liquidator;

    constructor(
        LendingPool lendingPool_,
        address alice_,
        address bob_,
        address carol_,
        address liquidator_
    ) {
        lendingPool = lendingPool_;
        alice = alice_;
        bob = bob_;
        carol = carol_;
        liquidator = liquidator_;

        actors.push(alice_);
        actors.push(bob_);
        actors.push(carol_);
    }

    function deposit(uint256 actorSeed, uint96 amountEth) external {
        address actor = actors[actorSeed % actors.length];
        uint256 amount = bound(uint256(amountEth), 1 wei, 5 ether);

        vm.prank(actor);
        try lendingPool.depositCollateral{value: amount}() {} catch {}
    }

    function borrow(uint256 actorSeed, uint96 amountIcft) external {
        address actor = actors[actorSeed % actors.length];
        uint256 maxBorrow = lendingPool.getAvailableBorrow(actor);
        if (maxBorrow == 0) return;

        uint256 amount = bound(uint256(amountIcft), 1 wei, maxBorrow);

        vm.prank(actor);
        try lendingPool.borrow(amount) {} catch {}
    }

    function repay(uint256 actorSeed, uint96 amountIcft) external {
        address actor = actors[actorSeed % actors.length];
        uint256 amount = bound(uint256(amountIcft), 1 wei, 1_000 ether);

        vm.prank(actor);
        try lendingPool.repay(amount) {} catch {}
    }

    function withdraw(uint256 actorSeed, uint96 amountEth) external {
        address actor = actors[actorSeed % actors.length];
        ILendingPoolPosition memory position = _getPosition(actor);
        if (position.collateralETH == 0) return;

        uint256 amount = bound(uint256(amountEth), 1 wei, position.collateralETH);

        vm.prank(actor);
        try lendingPool.withdrawCollateral(amount) {} catch {}
    }

    function warpTime(uint32 timeJump) external {
        vm.warp(block.timestamp + bound(uint256(timeJump), 1 minutes, 7 days));
    }

    struct ILendingPoolPosition {
        uint256 collateralETH;
        uint256 principalDebtUSD;
        uint256 scaledDebtUSD;
        uint256 lastAccrualIndex;
        bool active;
    }

    function _getPosition(address actor) internal view returns (ILendingPoolPosition memory position) {
        (
            uint256 collateralETH,
            uint256 principalDebtUSD,
            uint256 scaledDebtUSD,
            uint256 lastAccrualIndex,
            bool active
        ) = lendingPool.positions(actor);

        position = ILendingPoolPosition({
            collateralETH: collateralETH,
            principalDebtUSD: principalDebtUSD,
            scaledDebtUSD: scaledDebtUSD,
            lastAccrualIndex: lastAccrualIndex,
            active: active
        });
    }
}

contract ICFTProtocolInvariantTest is StdInvariant, ProtocolFixture {
    ProtocolHandler internal handler;

    function setUp() public {
        _setUpProtocol();
        handler = new ProtocolHandler(lendingPool, alice, bob, carol, liquidator);
        targetContract(address(handler));
    }

    function invariant_TotalBorrowedNeverExceedsFundAAllocation() public view {
        assertLe(lendingPool.totalBorrowedICFT(), FUND_A);
    }

    function invariant_FundALiquidityNeverExceedsAllocation() public view {
        assertLe(lendingPool.fundALiquidityICFT(), FUND_A);
    }

    function invariant_AvailableLiquidityNeverExceedsFundALiquidity() public view {
        assertLe(lendingPool.getAvailableLiquidity(), lendingPool.fundALiquidityICFT());
    }

    function invariant_SpendablePrincipalBalanceIsBoundedByRawBalance() public view {
        assertLe(lendingPool.getSpendablePrincipalBalance(), icft.balanceOf(address(lendingPool)));
    }

    function invariant_ProtocolRevenueNeverExceedsRawBalance() public view {
        assertLe(lendingPool.protocolRevenueICFT(), icft.balanceOf(address(lendingPool)));
    }
}
