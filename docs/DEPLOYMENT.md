# Deployment Runbook

## Purpose

This document explains how to deploy the ICFT MVP protocol using Foundry scripts.

This repository is intended for **localhost-first development only**.

Do not treat this deployment flow as production-ready.
Do not treat this deployment flow as public-testnet-ready.

## Files

- `script/DeployICFTProtocol.s.sol`
- `.env.example`

## Prerequisites

- Foundry installed
- local Anvil node
- funded local deployer account
- local ETH/USD feed strategy for development

## Environment Setup

Copy `.env.example` into `.env` and fill the values:

```bash
cp .env.example .env
```

Minimum required values:

- `DEPLOYER_PRIVATE_KEY`
- `ETH_USD_FEED`
- `RPC_URL`

Recommended values to set explicitly:

- `ADMIN_ADDRESS`
- `FUND_A_HOLDER`
- `LIQUIDATION_OPERATOR`
- all token allocation recipient addresses

Defaults:

- most addresses default to the deployer address if not provided
- `INITIAL_MANUAL_ICFT_PRICE=1e8`
- `MAX_LTV_BPS=8000`
- `LIQUIDATION_THRESHOLD_BPS=9000`
- `TARGET_LTV_BPS=8500`
- `LIQUIDATION_BONUS_BPS=500`
- borrow curve defaults to the current MVP values

## Recommended Localhost Flow

Start a local chain:

```bash
anvil
```

Then in another shell:

```bash
cp .env.example .env
source .env
forge build
forge test
forge script script/DeployICFTProtocol.s.sol:DeployICFTProtocol \
  --rpc-url $RPC_URL \
  --broadcast
```

## Local Dry Run

```bash
source .env
forge script script/DeployICFTProtocol.s.sol:DeployICFTProtocol
```

## Optional Non-Local Broadcast

This is not the recommended mode for this repository stage, but the script can technically be pointed at another RPC.

```bash
source .env
forge script script/DeployICFTProtocol.s.sol:DeployICFTProtocol \
  --rpc-url $RPC_URL \
  --broadcast
```

Optional verification flow:

```bash
forge script script/DeployICFTProtocol.s.sol:DeployICFTProtocol \
  --rpc-url $RPC_URL \
  --broadcast \
  --verify
```

## Deployment Order

The script deploys:

1. `ICFT`
2. `PriceOracle`
3. `InterestRateModel`
4. `RiskEngine`
5. `LendingPool`
6. `LiquidationEngine`

Then it:

1. grants the pool liquidation role to `LiquidationEngine`
2. grants `LiquidationEngine` operator role to `LIQUIDATION_OPERATOR`
3. transfers `Fund A` allocation to `LendingPool` if `FUND_A_HOLDER` equals the deployer

## Important Operational Note

If `FUND_A_HOLDER` is not the deployer address, the script cannot move Fund A automatically.

In that case, after deployment you must manually transfer `FUND_A_ALLOCATION` ICFT to `LendingPool`.

## Post-Deployment Checklist

Verify onchain:

1. `ICFT.totalSupply() == 1_000_000_000e18`
2. `LendingPool.fundALiquidityICFT() == FUND_A_ALLOCATION` after Fund A is transferred
3. `PriceOracle.getICFTUSDPrice()` returns the intended manual MVP price
4. `LiquidationEngine` has been granted pool liquidation rights
5. `LIQUIDATION_OPERATOR` has operator role in `LiquidationEngine`

## Suggested Local Sanity Checks

After deployment, test:

1. deposit ETH collateral
2. borrow a small ICFT amount
3. repay partially
4. repay fully
5. withdraw collateral
6. update manual ICFT price through the oracle admin

## Known MVP Limitations

- ICFT/USD is manually configured
- liquidation settlement is simplified
- no production governance layer
- no production treasury / vesting layer
- no production market-liquidity integration
- not suitable for real public deployment in its current stage
