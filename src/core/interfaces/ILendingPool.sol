// SPDX-License-Identifier: GPL-3.0-only
pragma solidity ^0.8.20;

import {IPriceOracle} from "./IPriceOracle.sol";
import {IRiskEngine} from "./IRiskEngine.sol";

/**
 * @title ILendingPool
 * @notice Canonical lending-pool interface for collateral, debt, and liquidation state.
 * @dev Borrowing is denominated in ICFT while debt is tracked in internal USD accounting units.
 *
 * @custom:version 1.0.0
 */
interface ILendingPool {
    /**
     * @notice Stores a user's collateral and debt state.
     * @param collateralETH ETH collateral balance in wei.
     * @param principalDebtUSD Principal debt using internal 1e18 USD precision.
     * @param accruedInterestUSD Accrued but unpaid interest using internal 1e18 USD precision.
     * @param lastInterestUpdate Timestamp of the last interest accrual checkpoint.
     * @param active Whether the position should be treated as active by integrations and indexing.
     */
    struct Position {
        uint256 collateralETH;
        uint256 principalDebtUSD;
        uint256 accruedInterestUSD;
        uint256 lastInterestUpdate;
        bool active;
    }

    /**
     * @notice Emitted when a user deposits ETH collateral.
     * @param user Borrower whose position was updated.
     * @param amountETH ETH amount added in wei.
     * @param totalCollateralETH User's resulting collateral balance in wei.
     */
    event DepositCollateral(address indexed user, uint256 amountETH, uint256 totalCollateralETH);

    /**
     * @notice Emitted when a user withdraws ETH collateral.
     * @param user Borrower whose position was updated.
     * @param amountETH ETH amount withdrawn in wei.
     * @param remainingCollateralETH User's remaining collateral balance in wei.
     */
    event WithdrawCollateral(address indexed user, uint256 amountETH, uint256 remainingCollateralETH);

    /**
     * @notice Emitted when a user borrows ICFT.
     * @param user Borrower whose debt was increased.
     * @param amountICFT ICFT amount transferred to the borrower.
     * @param addedDebtUSD Principal debt added in internal USD units.
     * @param totalDebtUSD Borrower's resulting total debt in internal USD units.
     */
    event Borrow(address indexed user, uint256 amountICFT, uint256 addedDebtUSD, uint256 totalDebtUSD);

    /**
     * @notice Emitted when a user repays debt with ICFT.
     * @param user Borrower whose debt was reduced.
     * @param amountICFT ICFT amount taken from the borrower.
     * @param repaidDebtUSD Debt value extinguished in internal USD units.
     * @param remainingDebtUSD Borrower's remaining total debt in internal USD units.
     */
    event Repay(address indexed user, uint256 amountICFT, uint256 repaidDebtUSD, uint256 remainingDebtUSD);

    /**
     * @notice Emitted when a position is liquidated.
     * @param user Borrower whose position was liquidated.
     * @param liquidator Authorized liquidation caller that repaid ICFT.
     * @param repaidICFT ICFT amount consumed during liquidation.
     * @param repaidDebtUSD Debt value extinguished in internal USD units.
     * @param collateralSeizedETH ETH collateral seized in wei.
     * @param resultingLtvBps Borrower's resulting LTV after liquidation, in basis points.
     */
    event Liquidation(
        address indexed user,
        address indexed liquidator,
        uint256 repaidICFT,
        uint256 repaidDebtUSD,
        uint256 collateralSeizedETH,
        uint256 resultingLtvBps
    );

    /**
     * @notice Emitted when interest is accrued onto a position.
     * @param user Borrower whose debt was updated.
     * @param interestUSD Newly accrued interest in internal USD units.
     * @param totalAccruedInterestUSD Position-level accrued interest after the update.
     */
    event InterestAccrued(address indexed user, uint256 interestUSD, uint256 totalAccruedInterestUSD);

    /**
     * @notice Emitted when a mutable pool parameter is updated.
     * @param parameter Identifier for the updated parameter.
     * @param value New parameter value.
     */
    event ParameterUpdated(bytes32 indexed parameter, uint256 value);

    /**
     * @notice Emitted when aggregate Fund A accounting values change.
     * @param fundALiquidityICFT ICFT principal still assigned to Fund A liquidity.
     * @param totalBorrowedICFT Total ICFT currently borrowed by users.
     * @param totalPrincipalDebtUSD Aggregate protocol principal debt in internal USD units.
     * @param totalAccruedInterestUSD Aggregate unpaid interest in internal USD units.
     * @param protocolRevenueICFT ICFT revenue attributable to interest spread.
     */
    event FundAAccountingUpdated(
        uint256 fundALiquidityICFT,
        uint256 totalBorrowedICFT,
        uint256 totalPrincipalDebtUSD,
        uint256 totalAccruedInterestUSD,
        uint256 protocolRevenueICFT
    );

    /**
     * @notice Repays a liquidatable position and transfers seized collateral to the recipient.
     * @param user Borrower being liquidated.
     * @param maxICFTToRepay Maximum ICFT the caller is willing to repay.
     * @param collateralRecipient Address that should receive seized ETH.
     */
    function liquidate(address user, uint256 maxICFTToRepay, address collateralRecipient) external;

    /**
     * @notice Returns a user's total debt in internal USD accounting units.
     * @param user Borrower address.
     * @return debtUSD Total debt including accrued interest, using 1e18 precision.
     */
    function getDebt(address user) external view returns (uint256);

    /**
     * @notice Returns the raw stored user position.
     * @param user Borrower address.
     * @return position Stored position snapshot.
     */
    function getPosition(address user) external view returns (Position memory);

    /**
     * @notice Returns whether the user is liquidatable at current prices.
     * @param user Borrower address.
     * @return liquidatable True when the position is eligible for liquidation.
     */
    function isLiquidatable(address user) external view returns (bool);

    /**
     * @notice Returns the risk engine used by the pool.
     * @return engine Risk engine contract reference.
     */
    function riskEngine() external view returns (IRiskEngine);

    /**
     * @notice Returns the price oracle used by the pool.
     * @return oracle Price oracle contract reference.
     */
    function priceOracle() external view returns (IPriceOracle);
}
