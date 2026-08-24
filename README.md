# ICFT Frontend

A React + TypeScript + Vite frontend for the current ICFT localhost/Anvil lending MVP.

## What is implemented

- ICFT-branded landing page matching the supplied dark blue / white / cyan visual direction.
- Injected wallet connection (MetaMask and compatible EIP-1193 wallets).
- Local Anvil chain support (default chain id 31337).
- Reads real ICFT, LendingPool, RiskEngine, PriceOracle and InterestRateModel state.
- Deposit ETH collateral.
- Borrow ICFT.
- Approve + repay ICFT.
- Withdraw ETH collateral.
- Live collateral, debt, LTV, health factor, oracle prices, APR, utilization and available liquidity.
- Transaction confirmation and error states.
- Markets and documentation sections without fake liquidity or fake protocol statistics.

## Important

The repository currently describes the smart contracts as localhost/Anvil-only and not safe for real funds. This frontend follows that boundary.

## Setup

1. Make sure Anvil is running.
2. Deploy the ICFT contracts using the repository's Foundry deployment script.
3. Copy `.env.example` to `.env`.
4. Put the addresses printed by `DeployICFTProtocol.s.sol` into `.env`:

```env
VITE_RPC_URL=http://127.0.0.1:8545
VITE_CHAIN_ID=31337
VITE_ICFT_ADDRESS=0x...
VITE_LENDING_POOL_ADDRESS=0x...
VITE_RISK_ENGINE_ADDRESS=0x...
VITE_PRICE_ORACLE_ADDRESS=0x...
VITE_INTEREST_RATE_MODEL_ADDRESS=0x...
```

5. Install and start:

```bash
npm install
npm run dev
```

6. Open `http://localhost:5173`.
7. Add the Anvil local network to MetaMask and import one of the Anvil test accounts if needed.

## Contract calls used

LendingPool:
- `depositCollateral()` payable
- `borrow(uint256)`
- `repay(uint256)`
- `withdrawCollateral(uint256)`
- `getPosition(address)`
- `getDebt(address)`
- `getLTV(address)`
- `getCollateralValueUSD(address)`
- `getCurrentInterest(address)`
- `getAvailableBorrow(address)`
- `getAvailableLiquidity()`
- `getUtilization()`
- `paused()`

ICFT:
- `balanceOf(address)`
- `allowance(address,address)`
- `approve(address,uint256)`

RiskEngine:
- `getMaxLTVBps()`
- `getLiquidationThresholdBps()`

PriceOracle:
- `getETHUSDPrice()`
- `getICFTUSDPrice()`

InterestRateModel:
- `getBorrowRateBps(uint256)`

## Notes

The frontend does not implement liquidation UI for normal users because the current MVP routes pool liquidation through an authorized liquidation operator. It also does not pretend ICFT/USDT liquidity exists on-chain yet; the repository marks that as a later phase.
