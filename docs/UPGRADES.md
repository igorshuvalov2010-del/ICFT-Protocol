# Upgrade Runbook

## Purpose

This document explains how to upgrade one ICFT proxy at a time with the Foundry script:

- `script/UpgradeICFTModule.s.sol`

This flow is for the current upgradeable testnet stage.
It is not a production governance process.

## Supported Modules

Set `MODULE` to one of:

- `ICFT`
- `PriceOracle`
- `InterestRateModel`
- `RiskEngine`
- `LendingPool`
- `LiquidationEngine`

## Required Environment Variables

- `RPC_URL`
- `DEPLOYER_PRIVATE_KEY`
- `PROXY_ADMIN_ADDRESS`
- `PROXY_ADDRESS`
- `MODULE`

Optional:

- `UPGRADE_CALLDATA`

Use `UPGRADE_CALLDATA` only when the new implementation adds a post-upgrade initializer or migration function.
If not needed, leave it empty.

## Dry Run

```bash
source .env
forge script script/UpgradeICFTModule.s.sol:UpgradeICFTModule \
  --rpc-url "$RPC_URL" \
  -vvvv
```

## Broadcast

```bash
source .env
forge script script/UpgradeICFTModule.s.sol:UpgradeICFTModule \
  --rpc-url "$RPC_URL" \
  --broadcast \
  -vvvv
```

## Example

Upgrade the lending pool proxy:

```bash
source .env
export MODULE=LendingPool
export PROXY_ADMIN_ADDRESS=<proxy-admin-address>
export PROXY_ADDRESS=<lending-pool-proxy-address>

forge script script/UpgradeICFTModule.s.sol:UpgradeICFTModule \
  --rpc-url "$RPC_URL" \
  --broadcast \
  -vvvv
```

## Post-Upgrade Checks

After each upgrade:

1. confirm the proxy still returns expected state
2. rerun a few critical reads like collateral balances, debt, and borrow index
3. confirm role-gated actions still work
4. confirm the upgraded implementation address in the explorer
5. if migration calldata was used, verify the migrated fields directly

## Safety Notes

- upgrade only one proxy per transaction flow
- never combine an upgrade with unrelated admin changes
- keep `ProxyAdmin` ownership off a casual hot wallet when moving beyond basic testnet rehearsal
- if storage layout changes, review it before broadcasting
- if a deployer or admin private key was ever exposed in chat, logs, or screenshots, rotate it before the next upgrade

## Current Module Notes

As of September 1, 2026:

- `PriceOracle` upgrades are especially sensitive because collateral-feed storage must remain append-only for proxy safety;
- `LendingPool` upgrades are especially sensitive because collateral registry storage and debt accounting storage must not be reordered;
- if enabling new collateral after deployment, the upgrade itself is not enough: the team must still execute the required admin calls in `PriceOracle` and `LendingPool`.

For the current Sepolia engineering baseline:

- `wBTC` enablement depends on a valid token address and trusted price feed for that network;
- `wstETH` enablement currently depends on a documented testnet-only oracle path;
- post-upgrade verification should always include `getSupportedCollateralAssets()` and oracle support checks for every enabled collateral asset.
