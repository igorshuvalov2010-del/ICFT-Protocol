// SPDX-License-Identifier: GPL-3.0-only
pragma solidity ^0.8.20;

import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import {Pausable} from "@openzeppelin/contracts/utils/Pausable.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

import {IInterestRateModel} from "../../interfaces/IInterestRateModel.sol";
import {ILendingPool} from "../../interfaces/ILendingPool.sol";
import {IPriceOracle} from "../../interfaces/IPriceOracle.sol";
import {IRiskEngine} from "../../interfaces/IRiskEngine.sol";
import {
    BorrowExceedsLTV,
    BorrowingDisabledAtUtilization,
    DirectETHTransfersDisabled,
    EthTransferFailed,
    InsufficientCollateral,
    InsufficientLiquidity,
    InvalidAddress,
    NoDebt,
    NotLiquidatable,
    NothingToRepay,
    SlippageExceeded,
    ZeroAmount
} from "../../utils/Errors.sol";

/**
 * @title LendingPool
 * @notice Accepts ETH collateral and lends ICFT while tracking debt in internal USD units.
 * @dev The protocol borrows ICFT, not USDC or USDT. USD values are accounting-only 1e18 fixed-point numbers.
 * @dev Principal and interest are tracked separately so Fund A principal and protocol revenue can be accounted for.
 * @dev Interest accrues lazily on user interactions using the current utilization-derived APR from the rate model.
 * @dev Liquidations are restricted to an authorized bot role for the MVP operating model.
 *
 * @custom:version 1.0.0
 */
contract LendingPool is ILendingPool, AccessControl, Pausable, ReentrancyGuard {
    using SafeERC20 for IERC20;

    /// @notice Role allowed to pause and unpause the pool.
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");
    /// @notice Role allowed to update mutable pool configuration.
    bytes32 public constant CONFIG_ADMIN_ROLE = keccak256("CONFIG_ADMIN_ROLE");
    /// @notice Role allowed to execute pool-level liquidation calls.
    bytes32 public constant LIQUIDATION_BOT_ROLE = keccak256("LIQUIDATION_BOT_ROLE");

    /// @notice Basis-point denominator used across utilization and APR math.
    uint256 public constant BPS = 10_000;
    /// @notice Seconds per year used for simple-interest accrual.
    uint256 public constant YEAR = 365 days;

    /// @notice ICFT token lent out by the pool.
    IERC20 public immutable icft;
    /// @notice Price oracle used for ICFT/USD and ETH/USD conversions.
    IPriceOracle public immutable priceOracle;
    /// @notice Risk engine used for LTV and liquidation checks.
    IRiskEngine public immutable riskEngine;
    /// @notice Interest-rate model used to determine borrow APR from utilization.
    IInterestRateModel public immutable interestRateModel;

    /// @notice Total ICFT principal allocation initially assigned to Fund A liquidity.
    uint256 public immutable fundAAllocation;

    /// @notice Per-user collateral and debt positions.
    mapping(address => Position) public positions;

    /// @notice Amount of ICFT principal intentionally kept unavailable for new borrows.
    uint256 public liquidityBuffer;
    /// @notice Remaining ICFT principal still attributed to Fund A liquidity.
    uint256 public fundALiquidityICFT;
    /// @notice Aggregate ICFT principal currently borrowed by users.
    uint256 public totalBorrowedICFT;
    /// @notice Aggregate outstanding principal debt in internal USD units.
    uint256 public totalPrincipalDebtUSD;
    /// @notice Aggregate accrued but unpaid interest in internal USD units.
    uint256 public totalAccruedInterestUSD;
    /// @notice ICFT revenue attributable to interest spread and not counted as spendable principal.
    uint256 public protocolRevenueICFT;

    /**
     * @notice Creates the lending pool and wires all protocol dependencies.
     * @param admin Address that receives admin, pause, config, and liquidation roles.
     * @param icft_ ICFT token address.
     * @param priceOracle_ Oracle used for ETH/USD and ICFT/USD conversions.
     * @param riskEngine_ Risk engine used for health and liquidation checks.
     * @param interestRateModel_ Rate model used for utilization-based APR.
     * @param fundAAllocation_ Total ICFT principal assigned to Fund A liquidity.
     * @param liquidityBuffer_ Initial ICFT principal buffer that cannot be borrowed.
     */
    constructor(
        address admin,
        address icft_,
        address priceOracle_,
        address riskEngine_,
        address interestRateModel_,
        uint256 fundAAllocation_,
        uint256 liquidityBuffer_
    ) {
        if (
            admin == address(0) ||
            icft_ == address(0) ||
            priceOracle_ == address(0) ||
            riskEngine_ == address(0) ||
            interestRateModel_ == address(0)
        ) revert InvalidAddress();
        if (fundAAllocation_ == 0) revert ZeroAmount();

        _grantRole(DEFAULT_ADMIN_ROLE, admin);
        _grantRole(PAUSER_ROLE, admin);
        _grantRole(CONFIG_ADMIN_ROLE, admin);
        _grantRole(LIQUIDATION_BOT_ROLE, admin);

        // Persist immutable dependencies and initialize aggregate Fund A accounting state.
        icft = IERC20(icft_);
        priceOracle = IPriceOracle(priceOracle_);
        riskEngine = IRiskEngine(riskEngine_);
        interestRateModel = IInterestRateModel(interestRateModel_);
        fundAAllocation = fundAAllocation_;
        liquidityBuffer = liquidityBuffer_;
        fundALiquidityICFT = fundAAllocation_;
    }

    /// @notice Rejects plain ETH transfers so collateral accounting only happens through depositCollateral.
    receive() external payable {
        revert DirectETHTransfersDisabled();
    }

    /// @notice Deposits ETH as collateral for the caller.
    function depositCollateral() external payable nonReentrant whenNotPaused {
        if (msg.value == 0) revert ZeroAmount();

        Position storage position = positions[msg.sender];

        // Realize any pending interest before mutating user state so accounting stays monotonic.
        _accrueInterest(position, msg.sender);

        position.collateralETH += msg.value;
        position.lastInterestUpdate = block.timestamp;
        position.active = true;

        emit DepositCollateral(msg.sender, msg.value, position.collateralETH);
    }

    /**
     * @notice Withdraws collateral as long as the resulting position stays within max LTV.
     * @param amountETH ETH amount to withdraw in wei.
     */
    function withdrawCollateral(uint256 amountETH) external nonReentrant whenNotPaused {
        if (amountETH == 0) revert ZeroAmount();

        Position storage position = positions[msg.sender];
        _accrueInterest(position, msg.sender);

        if (amountETH > position.collateralETH) revert InsufficientCollateral();

        uint256 remainingCollateral = position.collateralETH - amountETH;
        uint256 currentDebtUSD = _getStoredDebt(position);

        // Re-check the position after the hypothetical withdrawal to prevent unhealthy exits.
        if (currentDebtUSD > 0) {
            uint256 resultingLtv = riskEngine.calculateLTV(remainingCollateral, currentDebtUSD);
            if (resultingLtv > riskEngine.getMaxLTVBps()) revert BorrowExceedsLTV();
        }

        position.collateralETH = remainingCollateral;
        position.lastInterestUpdate = block.timestamp;
        position.active = remainingCollateral > 0 || currentDebtUSD > 0;

        _sendEth(payable(msg.sender), amountETH);

        emit WithdrawCollateral(msg.sender, amountETH, remainingCollateral);
    }

    /**
     * @notice Borrows ICFT against the caller's ETH collateral.
     * @param amountICFT ICFT amount to borrow using 18 token decimals.
     */
    function borrow(uint256 amountICFT) external nonReentrant whenNotPaused {
        if (amountICFT == 0) revert ZeroAmount();

        Position storage position = positions[msg.sender];
        _accrueInterest(position, msg.sender);

        // Block borrows that would exceed current available principal or the configured utilization cap.
        uint256 availableLiquidity = getAvailableLiquidity();
        if (amountICFT > availableLiquidity) revert InsufficientLiquidity();

        uint256 projectedUtilization = _calculateUtilizationAfterBorrow(amountICFT);
        if (projectedUtilization >= interestRateModel.getMaxBorrowUtilizationBps()) {
            revert BorrowingDisabledAtUtilization();
        }

        uint256 addedDebtUSD = priceOracle.convertICFTToUSD(amountICFT);
        uint256 newDebtUSD = _getStoredDebt(position) + addedDebtUSD;
        uint256 newLtv = riskEngine.calculateLTV(position.collateralETH, newDebtUSD);
        if (newLtv > riskEngine.getMaxLTVBps()) revert BorrowExceedsLTV();

        // Update user debt and aggregate Fund A accounting before transferring the borrowed ICFT.
        position.principalDebtUSD += addedDebtUSD;
        position.lastInterestUpdate = block.timestamp;
        position.active = true;

        totalPrincipalDebtUSD += addedDebtUSD;
        fundALiquidityICFT -= amountICFT;
        totalBorrowedICFT += amountICFT;

        icft.safeTransfer(msg.sender, amountICFT);

        _emitFundAAccountingUpdate();
        emit Borrow(msg.sender, amountICFT, addedDebtUSD, newDebtUSD);
    }

    /**
     * @notice Repays part or all of the caller's debt using ICFT.
     * @param amountICFT Maximum ICFT amount the caller wants to repay.
     */
    function repay(uint256 amountICFT) external nonReentrant {
        if (amountICFT == 0) revert ZeroAmount();

        Position storage position = positions[msg.sender];
        _accrueInterest(position, msg.sender);

        uint256 totalDebtUSD = _getStoredDebt(position);
        if (totalDebtUSD == 0) revert NoDebt();

        uint256 fullRepayICFT = priceOracle.convertUSDToICFT(totalDebtUSD, true);
        uint256 actualICFT = amountICFT < fullRepayICFT ? amountICFT : fullRepayICFT;
        uint256 repaidDebtUSD = actualICFT == fullRepayICFT ? totalDebtUSD : priceOracle.convertICFTToUSD(actualICFT);

        if (repaidDebtUSD == 0) revert NothingToRepay();

        // Split repayment into interest and principal so Fund A principal and protocol revenue remain separable.
        (uint256 repaidInterestUSD, uint256 repaidPrincipalUSD) = _previewRepaymentBreakdown(position, repaidDebtUSD);
        (uint256 returnedPrincipalICFT, uint256 returnedRevenueICFT) =
            _splitReturnedICFT(actualICFT, repaidDebtUSD, repaidPrincipalUSD);

        icft.safeTransferFrom(msg.sender, address(this), actualICFT);
        _reduceDebt(position, repaidInterestUSD, repaidPrincipalUSD);
        position.lastInterestUpdate = block.timestamp;
        position.active = position.collateralETH > 0 || _getStoredDebt(position) > 0;

        fundALiquidityICFT += returnedPrincipalICFT;
        protocolRevenueICFT += returnedRevenueICFT;
        totalBorrowedICFT = _saturatingSub(totalBorrowedICFT, returnedPrincipalICFT);

        _emitFundAAccountingUpdate();
        emit Repay(msg.sender, actualICFT, repaidDebtUSD, _getStoredDebt(position));
    }

    /// @inheritdoc ILendingPool
    function liquidate(address user, uint256 maxICFTToRepay, address collateralRecipient)
        external
        nonReentrant
        whenNotPaused
        onlyRole(LIQUIDATION_BOT_ROLE)
    {
        if (collateralRecipient == address(0)) revert InvalidAddress();

        Position storage position = positions[user];
        _accrueInterest(position, user);

        uint256 totalDebtUSD = _getStoredDebt(position);
        if (totalDebtUSD == 0) revert NoDebt();
        if (!riskEngine.isLiquidatable(position.collateralETH, totalDebtUSD)) revert NotLiquidatable();

        IRiskEngine.LiquidationOutcome memory outcome = riskEngine.calculateLiquidation(position.collateralETH, totalDebtUSD);
        uint256 requiredICFT = priceOracle.convertUSDToICFT(outcome.debtToCoverUSD, true);

        // Require a valid liquidation slice and respect the caller's max repayment constraint.
        if (requiredICFT == 0 || outcome.collateralToSeizeETH == 0) revert NotLiquidatable();
        if (requiredICFT > maxICFTToRepay) revert SlippageExceeded();

        // Repay debt, update aggregate accounting, and transfer seized collateral to the requested recipient.
        (uint256 repaidInterestUSD, uint256 repaidPrincipalUSD) =
            _previewRepaymentBreakdown(position, outcome.debtToCoverUSD);
        (uint256 returnedPrincipalICFT, uint256 returnedRevenueICFT) =
            _splitReturnedICFT(requiredICFT, outcome.debtToCoverUSD, repaidPrincipalUSD);

        icft.safeTransferFrom(msg.sender, address(this), requiredICFT);

        _reduceDebt(position, repaidInterestUSD, repaidPrincipalUSD);

        position.collateralETH -= outcome.collateralToSeizeETH;
        position.lastInterestUpdate = block.timestamp;
        position.active = position.collateralETH > 0 || _getStoredDebt(position) > 0;

        fundALiquidityICFT += returnedPrincipalICFT;
        protocolRevenueICFT += returnedRevenueICFT;
        totalBorrowedICFT = _saturatingSub(totalBorrowedICFT, returnedPrincipalICFT);

        _sendEth(payable(collateralRecipient), outcome.collateralToSeizeETH);

        _emitFundAAccountingUpdate();
        emit Liquidation(
            user,
            msg.sender,
            requiredICFT,
            outcome.debtToCoverUSD,
            outcome.collateralToSeizeETH,
            outcome.resultingLtvBps
        );
    }

    /**
     * @notice Pauses collateral and borrow-side user actions.
     * @dev Repayments remain intentionally available while paused.
     */
    function pause() external onlyRole(PAUSER_ROLE) {
        _pause();
    }

    /**
     * @notice Unpauses the pool.
     */
    function unpause() external onlyRole(PAUSER_ROLE) {
        _unpause();
    }

    /**
     * @notice Updates the minimum ICFT liquidity buffer kept unavailable for borrowing.
     * @param newLiquidityBuffer New ICFT buffer amount.
     */
    function setLiquidityBuffer(uint256 newLiquidityBuffer) external onlyRole(CONFIG_ADMIN_ROLE) {
        liquidityBuffer = newLiquidityBuffer;
        emit ParameterUpdated(keccak256("liquidityBuffer"), newLiquidityBuffer);
    }

    /// @inheritdoc ILendingPool
    function getPosition(address user) external view returns (Position memory) {
        return positions[user];
    }

    /// @inheritdoc ILendingPool
    function getDebt(address user) public view returns (uint256) {
        Position memory position = positions[user];
        return _previewDebt(position);
    }

    /**
     * @notice Returns the current LTV for a user in basis points.
     * @param user Borrower address.
     * @return ltvBps Current LTV in basis points.
     */
    function getLTV(address user) external view returns (uint256) {
        Position memory position = positions[user];
        return riskEngine.calculateLTV(position.collateralETH, _previewDebt(position));
    }

    /**
     * @notice Returns current pool utilization in basis points.
     * @return utilizationBps Utilization in basis points.
     */
    function getUtilization() public view returns (uint256) {
        return _calculateUtilization(totalBorrowedICFT);
    }

    /**
     * @notice Returns the USD accounting value of the user's collateral.
     * @param user Borrower address.
     * @return collateralValueUSD Collateral value in internal USD units.
     */
    function getCollateralValueUSD(address user) external view returns (uint256) {
        return riskEngine.getCollateralValueUSD(positions[user].collateralETH);
    }

    /**
     * @notice Returns accrued interest including not-yet-stored interest since the last update.
     * @param user Borrower address.
     * @return accruedInterestUSD Position interest in internal USD units.
     */
    function getCurrentInterest(address user) external view returns (uint256) {
        Position memory position = positions[user];
        return _previewAccruedInterest(position);
    }

    /**
     * @notice Returns the maximum additional ICFT the user can currently borrow.
     * @param user Borrower address.
     * @return availableBorrowICFT Maximum additional ICFT borrowable right now.
     */
    function getAvailableBorrow(address user) external view returns (uint256) {
        Position memory position = positions[user];
        uint256 debtUSD = _previewDebt(position);
        uint256 maxBorrowUSD = riskEngine.getMaxBorrowUSD(position.collateralETH);

        if (maxBorrowUSD <= debtUSD) return 0;

        uint256 remainingBorrowUSD = maxBorrowUSD - debtUSD;
        uint256 remainingBorrowICFT = priceOracle.convertUSDToICFT(remainingBorrowUSD, false);
        uint256 availableLiquidity = getAvailableLiquidity();

        return remainingBorrowICFT < availableLiquidity ? remainingBorrowICFT : availableLiquidity;
    }

    /// @inheritdoc ILendingPool
    function isLiquidatable(address user) external view returns (bool) {
        Position memory position = positions[user];
        return riskEngine.isLiquidatable(position.collateralETH, _previewDebt(position));
    }

    /**
     * @notice Returns ICFT liquidity available for new borrows after the configured buffer.
     * @return availableLiquidityICFT ICFT principal available to lend.
     */
    function getAvailableLiquidity() public view returns (uint256) {
        uint256 spendablePrincipalBalance = getSpendablePrincipalBalance();
        uint256 principalInventory = fundALiquidityICFT < spendablePrincipalBalance ? fundALiquidityICFT : spendablePrincipalBalance;

        if (principalInventory <= liquidityBuffer) return 0;

        return principalInventory - liquidityBuffer;
    }

    /**
     * @notice Returns the ICFT principal inventory excluding protocol revenue held by the pool.
     * @return spendablePrincipalICFT Principal inventory still usable for lending.
     */
    function getSpendablePrincipalBalance() public view returns (uint256) {
        uint256 rawBalance = icft.balanceOf(address(this));
        return _saturatingSub(rawBalance, protocolRevenueICFT);
    }

    /**
     * @notice Accrues pending interest onto a position and global accounting.
     * @param position User position storage pointer.
     * @param user Borrower address used for event emission.
     */
    function _accrueInterest(Position storage position, address user) internal {
        if (position.lastInterestUpdate == 0) {
            position.lastInterestUpdate = block.timestamp;
            return;
        }

        uint256 accrued = _previewIncrementalInterest(position);
        if (accrued > 0) {
            position.accruedInterestUSD += accrued;
            totalAccruedInterestUSD += accrued;
            emit InterestAccrued(user, accrued, position.accruedInterestUSD);
        }

        position.lastInterestUpdate = block.timestamp;
    }

    /**
     * @notice Returns total debt including freshly previewed interest.
     * @param position Position snapshot.
     * @return debtUSD Total debt in internal USD units.
     */
    function _previewDebt(Position memory position) internal view returns (uint256) {
        return _getStoredDebt(position) + _previewIncrementalInterest(position);
    }

    /**
     * @notice Returns accrued interest including any not-yet-materialized incremental interest.
     * @param position Position snapshot.
     * @return accruedInterestUSD Total accrued interest in internal USD units.
     */
    function _previewAccruedInterest(Position memory position) internal view returns (uint256) {
        return position.accruedInterestUSD + _previewIncrementalInterest(position);
    }

    /**
     * @notice Previews incremental simple interest since the last accrual checkpoint.
     * @param position Position snapshot.
     * @return incrementalInterestUSD Pending interest in internal USD units.
     */
    function _previewIncrementalInterest(Position memory position) internal view returns (uint256) {
        if (position.lastInterestUpdate == 0 || position.principalDebtUSD == 0 || block.timestamp <= position.lastInterestUpdate) {
            return 0;
        }

        // Use current pool utilization to derive the APR applied to the user's principal balance.
        uint256 elapsed = block.timestamp - position.lastInterestUpdate;
        uint256 aprBps = interestRateModel.getBorrowRateBps(getUtilization());

        return (position.principalDebtUSD * aprBps * elapsed) / (BPS * YEAR);
    }

    /**
     * @notice Returns stored debt without previewing any new interest.
     * @param position Position snapshot.
     * @return storedDebtUSD Stored principal plus stored accrued interest.
     */
    function _getStoredDebt(Position memory position) internal pure returns (uint256) {
        return position.principalDebtUSD + position.accruedInterestUSD;
    }

    /**
     * @notice Reduces a user's stored debt buckets and global aggregates after repayment or liquidation.
     * @param position User position storage pointer.
     * @param repaidInterestUSD Interest portion repaid in internal USD units.
     * @param repaidPrincipalUSD Principal portion repaid in internal USD units.
     */
    function _reduceDebt(Position storage position, uint256 repaidInterestUSD, uint256 repaidPrincipalUSD) internal {
        if (repaidInterestUSD > 0) {
            position.accruedInterestUSD -= repaidInterestUSD;
            totalAccruedInterestUSD -= repaidInterestUSD;
        }

        if (repaidPrincipalUSD > 0) {
            position.principalDebtUSD -= repaidPrincipalUSD;
            totalPrincipalDebtUSD -= repaidPrincipalUSD;
        }
    }

    /**
     * @notice Returns projected utilization after an additional borrow.
     * @param amountICFT Additional ICFT principal to borrow.
     * @return utilizationBps Projected utilization in basis points.
     */
    function _calculateUtilizationAfterBorrow(uint256 amountICFT) internal view returns (uint256) {
        return _calculateUtilization(totalBorrowedICFT + amountICFT);
    }

    /**
     * @notice Calculates pool utilization relative to the original Fund A allocation.
     * @param borrowedICFT Borrowed ICFT principal amount.
     * @return utilizationBps Utilization in basis points.
     */
    function _calculateUtilization(uint256 borrowedICFT) internal view returns (uint256) {
        return (borrowedICFT * BPS) / fundAAllocation;
    }

    /**
     * @notice Splits a debt repayment into interest and principal buckets.
     * @param position Position snapshot.
     * @param repaidDebtUSD Total debt value being extinguished in internal USD units.
     * @return repaidInterestUSD Interest component of the repayment.
     * @return repaidPrincipalUSD Principal component of the repayment.
     */
    function _previewRepaymentBreakdown(Position memory position, uint256 repaidDebtUSD)
        internal
        pure
        returns (uint256 repaidInterestUSD, uint256 repaidPrincipalUSD)
    {
        repaidInterestUSD = repaidDebtUSD < position.accruedInterestUSD ? repaidDebtUSD : position.accruedInterestUSD;
        repaidPrincipalUSD = repaidDebtUSD - repaidInterestUSD;

        if (repaidPrincipalUSD > position.principalDebtUSD) {
            repaidPrincipalUSD = position.principalDebtUSD;
        }
    }

    /**
     * @notice Splits returned ICFT between restored principal liquidity and protocol revenue.
     * @param totalReturnedICFT Total ICFT returned to the pool.
     * @param repaidDebtUSD Total debt value extinguished in internal USD units.
     * @param repaidPrincipalUSD Principal portion of the extinguished debt.
     * @return returnedPrincipalICFT ICFT attributed back to Fund A principal.
     * @return returnedRevenueICFT ICFT attributed to protocol revenue.
     */
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

    /**
     * @notice Emits the aggregate Fund A accounting snapshot.
     */
    function _emitFundAAccountingUpdate() internal {
        emit FundAAccountingUpdated(
            fundALiquidityICFT,
            totalBorrowedICFT,
            totalPrincipalDebtUSD,
            totalAccruedInterestUSD,
            protocolRevenueICFT
        );
    }

    /**
     * @notice Sends ETH and reverts on transfer failure.
     * @param recipient ETH recipient.
     * @param amount ETH amount in wei.
     */
    function _sendEth(address payable recipient, uint256 amount) internal {
        (bool success,) = recipient.call{value: amount}("");
        if (!success) revert EthTransferFailed();
    }

    /**
     * @notice Returns `a - b`, saturating at zero instead of reverting.
     * @param a Left operand.
     * @param b Right operand.
     * @return result Saturating subtraction result.
     */
    function _saturatingSub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a > b ? a - b : 0;
    }
}
