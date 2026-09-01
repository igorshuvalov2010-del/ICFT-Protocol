# Deployment Runbook

## Purpose

This document explains how to deploy the ICFT protocol using the upgradeable Foundry deployment script.

This repository is currently between two stages:

- completed localhost MVP baseline;
- live but early upgradeable Sepolia baseline.

Do not treat this deployment flow as production-ready.
Do not treat this deployment flow as mainnet-ready.
Do not reuse exposed private keys or casual hot wallets for long-lived admin authority.

## Files

- `script/DeployICFTProtocol.s.sol`
- `script/UpgradeICFTModule.s.sol`
- `.env.example`
- `.env.sepolia.example`

## Prerequisites

- Foundry installed
- local Anvil node
- funded local deployer account
- local ETH/USD feed strategy for development
- Sepolia RPC provider if you deploy publicly
- Sepolia ETH for the deployer account
- Etherscan API key if you want source verification

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
- `UPGRADE_ADMIN_ADDRESS`
- `FUND_A_HOLDER`
- `LIQUIDATION_OPERATOR`
- all token allocation recipient addresses

Optional multi-collateral values:

- `ENABLE_WBTC_COLLATERAL`
- `WBTC_COLLATERAL_ASSET`
- `WBTC_USD_FEED`
- `WBTC_ASSET_DECIMALS`
- `ENABLE_WSTETH_COLLATERAL`
- `WSTETH_COLLATERAL_ASSET`
- `WSTETH_USD_FEED`
- `WSTETH_ASSET_DECIMALS`

Defaults:

- most addresses default to the deployer address if not provided
- `UPGRADE_ADMIN_ADDRESS` defaults to `ADMIN_ADDRESS`
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

## Recommended Sepolia Flow

As of September 1, 2026, Ethereum Sepolia is the active public testnet used by this repository.

Prepare the environment:

```bash
cp .env.sepolia.example .env
```

Fill at minimum:

- `RPC_URL`
- `DEPLOYER_PRIVATE_KEY`
- `ADMIN_ADDRESS`
- `UPGRADE_ADMIN_ADDRESS`
- `ETHERSCAN_API_KEY` if verifying

Use the default Sepolia ETH/USD feed unless Chainlink changes guidance for your target network:

- `ETH_USD_FEED=0x694AA1769357215DE4FAC081bf1f309aDC325306`

If you want `wBTC` collateral enabled on testnet, provide:

- a deployed ERC20 token address for that network
- a trusted USD price feed for that asset on that network
- the correct token decimals

If you want `wstETH` collateral enabled on testnet, provide:

- a deployed ERC20 token address for that network
- a trusted USD price feed for that asset on that network
- the correct token decimals

Current engineering note:

- Sepolia `wstETH` can be used as a token asset for testing, but the recommended flow in this repo currently uses a mock `wstETH/USD` feed;
- that mock-feed path is acceptable for protocol testing and UI integration, but it must be replaced before any production-like deployment;
- Sepolia `wBTC` may also be a test token rather than a canonical production wrapped-BTC deployment, so its address must be documented explicitly by the team.

If one of those pieces is missing, leave the asset disabled and deploy only the assets that are fully configured.

Run a dry simulation first:

```bash
source .env
forge build
forge test
forge script script/DeployICFTProtocol.s.sol:DeployICFTProtocol \
  --rpc-url $RPC_URL \
  -vvvv
```

Broadcast to Sepolia:

```bash
source .env
forge script script/DeployICFTProtocol.s.sol:DeployICFTProtocol \
  --rpc-url $RPC_URL \
  --broadcast \
  -vvvv
```

Broadcast and verify:

```bash
source .env
forge script script/DeployICFTProtocol.s.sol:DeployICFTProtocol \
  --rpc-url $RPC_URL \
  --broadcast \
  --verify \
  --etherscan-api-key $ETHERSCAN_API_KEY \
  -vvvv
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

The script deploys implementations for:

1. `ICFT`
2. `PriceOracle`
3. `InterestRateModel`
4. `RiskEngine`
5. `LendingPool`
6. `LiquidationEngine`

Then it deploys a transparent proxy for each implementation and initializes the proxy state.

Then it:

1. grants the pool liquidation role to `LiquidationEngine`
2. grants `LiquidationEngine` operator role to `LIQUIDATION_OPERATOR`
3. registers `wBTC` and `wstETH` in `PriceOracle` and `LendingPool` when each asset is enabled and the deployer is also the protocol admin
4. transfers `Fund A` allocation to `LendingPool` if `FUND_A_HOLDER` equals the deployer

The script also prints:

1. implementation addresses
2. proxy addresses
3. proxy admin addresses

## Important Operational Notes

If `ADMIN_ADDRESS` is not the deployer address, the script cannot grant post-initialization roles automatically.

In that case, after deployment you must manually:

1. grant `LIQUIDATION_BOT_ROLE` on `LendingPool` to `LiquidationEngine`
2. grant `OPERATOR_ROLE` on `LiquidationEngine` to `LIQUIDATION_OPERATOR`

If `FUND_A_HOLDER` is not the deployer address, the script cannot move Fund A automatically.

In that case, after deployment you must manually transfer `FUND_A_ALLOCATION` ICFT to `LendingPool`.

## Post-Deployment Checklist

Verify onchain:

1. `ICFT.totalSupply() == 1_000_000_000e18`
2. `LendingPool.fundALiquidityICFT() == FUND_A_ALLOCATION` after Fund A is transferred
3. `PriceOracle.getICFTUSDPrice()` returns the intended manual MVP price
4. every proxy has the expected implementation and proxy admin owner
5. `LiquidationEngine` has been granted pool liquidation rights
6. `LIQUIDATION_OPERATOR` has operator role in `LiquidationEngine`
7. `PriceOracle.getETHUSDPrice()` is reading live Sepolia Chainlink data
8. `PriceOracle.maxPriceAge()` matches your operational tolerance
9. `PriceOracle.isCollateralAssetSupported(wBTC)` matches your intended enabled/disabled state
10. `PriceOracle.isCollateralAssetSupported(wstETH)` matches your intended enabled/disabled state
11. `LendingPool.getSupportedCollateralAssets()` contains the intended collateral basket
12. `ProxyAdmin` ownership is in the intended upgrade admin address, not an accidental hot wallet
13. no deployer private key used during testing has been exposed or reused after being shared insecurely

## Suggested Local Sanity Checks

After deployment, test:

1. deposit ETH collateral
2. deposit `wBTC` collateral if enabled
3. deposit `wstETH` collateral if enabled
4. borrow a small ICFT amount
5. repay partially
6. repay fully
7. withdraw collateral
8. update manual ICFT price through the oracle admin

## Current Sepolia Baseline

The current public-testnet baseline supports:

- transparent proxy deployment for all stateful modules;
- post-deploy collateral registration for `ETH`, `wBTC`, and `wstETH`;
- manual `ICFT/USD` pricing for MVP and early testnet usage;
- upgrade and migration flows through `script/UpgradeICFTModule.s.sol`.

This baseline still assumes:

- admin-driven oracle operations;
- a restricted liquidation operator model;
- testnet-only collateral and oracle substitutions where production infrastructure does not yet exist.

Before production or production-like staging, replace:

- exposed or casually managed deployer keys with a multisig or hardware-backed operational flow;
- mock feeds with production-grade oracle sources;
- ad hoc test tokens with canonical production collateral assets;
- manual operator procedures with documented incident, upgrade, and monitoring playbooks.

## Known MVP Limitations

- ICFT/USD is manually configured
- liquidation settlement is simplified
- rate-model changes still require careful operational sequencing around accrued debt
- no production governance layer
- no production treasury / vesting layer
- no production market-liquidity integration
- not suitable for real public deployment in its current stage

## Testnet Positioning

Use this stage for:

1. proxy upgrade rehearsals
2. role-management rehearsals
3. oracle and liquidation path validation
4. frontend and indexer integration
5. public bug discovery on low-value infrastructure

Do not use this stage for:

1. real value assumptions
2. irreversible token distribution commitments
3. claiming mainnet-level economic safety
