// SPDX-License-Identifier: GPL-3.0-only
pragma solidity ^0.8.20;

import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

import {ILiquidationEngine} from "../../interfaces/ILiquidationEngine.sol";
import {ILendingPool} from "../../interfaces/ILendingPool.sol";
import {IPriceOracle} from "../../interfaces/IPriceOracle.sol";
import {IRiskEngine} from "../../interfaces/IRiskEngine.sol";
import {EthTransferFailed, InvalidAddress, InvalidAmount, MaxRepayBelowRequired} from "../../utils/Errors.sol";

/**
 * @title LiquidationEngine
 * @notice Restricted liquidation helper that repays ICFT debt and forwards seized ETH.
 * @dev The helper wraps the pool's liquidation entrypoint so operators can work from a richer preview surface.
 * @dev Seized ETH is temporarily received by this contract and then forwarded to the chosen beneficiary.
 * @dev Access is intentionally role-restricted for the MVP bot-driven liquidation model.
 *
 * @custom:version 1.0.0
 */
contract LiquidationEngine is ILiquidationEngine, AccessControl, ReentrancyGuard {
    using SafeERC20 for IERC20;

    /// @notice Role allowed to administer engine configuration and operators.
    bytes32 public constant ENGINE_ADMIN_ROLE = keccak256("ENGINE_ADMIN_ROLE");
    /// @notice Role allowed to execute live liquidations.
    bytes32 public constant OPERATOR_ROLE = keccak256("OPERATOR_ROLE");

    /// @notice ICFT token used to repay debt during liquidations.
    IERC20 public immutable icft;
    /// @notice Lending pool against which liquidations are executed.
    ILendingPool public immutable lendingPool;

    /// @notice Total number of liquidation executions performed through this helper.
    uint256 public totalExecutions;
    /// @notice Aggregate ICFT consumed across all executions.
    uint256 public totalRepaidIcft;
    /// @notice Aggregate debt extinguished across all executions in internal USD units.
    uint256 public totalRepaidUsd;
    /// @notice Aggregate ETH seized across all executions in wei.
    uint256 public totalSeizedEth;

    /**
     * @notice Creates the liquidation engine and grants the admin the initial operator role.
     * @param admin Address that receives admin and engine roles.
     * @param icft_ ICFT token address used for debt repayment.
     * @param lendingPool_ Lending pool address that performs the core liquidation.
     */
    constructor(address admin, address icft_, address lendingPool_) {
        if (admin == address(0) || icft_ == address(0) || lendingPool_ == address(0)) revert InvalidAddress();

        _grantRole(DEFAULT_ADMIN_ROLE, admin);
        _grantRole(ENGINE_ADMIN_ROLE, admin);
        _grantRole(OPERATOR_ROLE, admin);

        icft = IERC20(icft_);
        lendingPool = ILendingPool(lendingPool_);
    }

    /// @notice Accepts ETH transferred from the pool during liquidation settlement.
    receive() external payable {}

    /// @inheritdoc ILiquidationEngine
    function previewLiquidation(address user) external view returns (LiquidationPreview memory preview) {
        uint256 debtUsd = lendingPool.getDebt(user);
        bool liquidatable = lendingPool.isLiquidatable(user);

        preview.isLiquidatable = liquidatable;
        preview.debtUsd = debtUsd;

        if (!liquidatable || debtUsd == 0) {
            return preview;
        }

        ILendingPool.Position memory position = lendingPool.getPosition(user);
        IRiskEngine.LiquidationOutcome memory outcome =
            IRiskEngine(lendingPool.riskEngine()).calculateLiquidation(position.collateralETH, debtUsd);

        preview.requiredIcft =
            IPriceOracle(lendingPool.priceOracle()).convertUSDToICFT(outcome.debtToCoverUSD, true);
        preview.collateralToSeizeEth = outcome.collateralToSeizeETH;
        preview.collateralValueSeizedUsd = outcome.collateralValueSeizedUSD;
        preview.resultingLtvBps = outcome.resultingLtvBps;
    }

    /// @inheritdoc ILiquidationEngine
    function executeLiquidation(address user, uint256 maxIcftToRepay, address payable collateralBeneficiary)
        external
        nonReentrant
        onlyRole(OPERATOR_ROLE)
        returns (uint256 repaidIcft, uint256 repaidUsd, uint256 seizedEth)
    {
        if (collateralBeneficiary == address(0)) revert InvalidAddress();
        if (maxIcftToRepay == 0) revert InvalidAmount();

        // Snapshot balances and debt before execution so post-call deltas can reconstruct actual settlement.
        LiquidationPreview memory preview = this.previewLiquidation(user);
        uint256 debtBefore = lendingPool.getDebt(user);
        uint256 ethBefore = address(this).balance;
        uint256 icftBefore = icft.balanceOf(address(this));
        uint256 requestedTransfer = preview.requiredIcft;

        if (requestedTransfer > maxIcftToRepay) {
            revert MaxRepayBelowRequired();
        }

        if (requestedTransfer == 0) {
            requestedTransfer = maxIcftToRepay;
        }

        // Pull ICFT from the operator and grant the pool only the exact amount needed for this attempt.
        icft.safeTransferFrom(msg.sender, address(this), requestedTransfer);
        icft.forceApprove(address(lendingPool), 0);
        icft.forceApprove(address(lendingPool), requestedTransfer);

        // Execute liquidation through the pool, which returns seized ETH to this helper.
        lendingPool.liquidate(user, maxIcftToRepay, address(this));

        uint256 debtAfter = lendingPool.getDebt(user);
        uint256 icftAfter = icft.balanceOf(address(this));
        uint256 ethAfter = address(this).balance;
        uint256 refundIcft = icftAfter > icftBefore ? icftAfter - icftBefore : 0;

        repaidUsd = debtBefore > debtAfter ? debtBefore - debtAfter : 0;
        repaidIcft = requestedTransfer - refundIcft;
        seizedEth = ethAfter - ethBefore;

        totalExecutions += 1;
        totalRepaidIcft += repaidIcft;
        totalRepaidUsd += repaidUsd;
        totalSeizedEth += seizedEth;

        // Refund any unused ICFT in cases where the operator over-provisioned relative to actual settlement.
        if (refundIcft > 0) {
            icft.safeTransfer(msg.sender, refundIcft);
        }

        // Forward the seized ETH to the requested beneficiary once settlement is complete.
        if (seizedEth > 0) {
            _sendEth(collateralBeneficiary, seizedEth);
        }

        emit LiquidationExecuted(
            user,
            msg.sender,
            collateralBeneficiary,
            repaidIcft,
            repaidUsd,
            seizedEth,
            previewResultingLtv(user)
        );
    }

    /**
     * @notice Returns the current post-state LTV for a borrower.
     * @param user Borrower address to inspect.
     * @return ltvBps Current user LTV in basis points.
     */
    function previewResultingLtv(address user) public view returns (uint256) {
        ILendingPool.Position memory position = lendingPool.getPosition(user);
        uint256 debtUsd = lendingPool.getDebt(user);
        return IRiskEngine(lendingPool.riskEngine()).calculateLTV(position.collateralETH, debtUsd);
    }

    /**
     * @notice Forwards ETH and reverts on failure.
     * @param recipient Address receiving ETH.
     * @param amount ETH amount in wei.
     */
    function _sendEth(address payable recipient, uint256 amount) internal {
        (bool success,) = recipient.call{value: amount}("");
        if (!success) revert EthTransferFailed();
    }
}
