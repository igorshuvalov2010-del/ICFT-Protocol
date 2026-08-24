# ICFT Protocol Code Guide

## Purpose

This repository contains the earliest executable MVP stage of the ICFT lending protocol.

This codebase is **not** ready for:

- mainnet
- public testnet
- real users
- real money

The correct environment for this snapshot is:

- `localhost`
- `anvil`
- developer machines
- architecture exploration
- unit/invariant/fuzz testing

## What This MVP Actually Does

The current system allows a developer to simulate the following flow:

1. a user deposits `ETH` as collateral
2. a user borrows `ICFT`
3. the protocol tracks debt in an internal `USD` accounting unit
4. interest accrues in that internal `USD` accounting unit
5. the user repays in `ICFT`
6. an authorized liquidator can partially liquidate unhealthy positions

Important:

- `USD` here is **not** a token
- it is **not** `USDC`
- it is **not** `USDT`
- it is only an internal value unit with `1e18` precision

## MVP Boundaries

This repository intentionally stops before production concerns are solved.

Not solved in this stage:

- real market liquidity routing
- robust keeper network design
- governance and multisig controls
- treasury management
- vesting contracts
- production oracle redundancy
- economic stress testing
- external integrations
- operational security for public deployments

Because of that, the repository should be treated as:

- a local prototype
- a code baseline
- a design and testing artifact

It should **not** be treated as a deploy-and-use protocol.

## Directory Map

### `src/core/ICFT/token`

- `ICFT.sol`
  Fixed-supply ERC-20 token with the requested token allocation split.

### `src/core/ICFT/oracle`

- `PriceOracle.sol`
  Oracle layer for:
  - `ETH/USD` via Chainlink
  - `ICFT/USD` via manual admin price or optional Chainlink source

### `src/core/ICFT/risk`

- `RiskEngine.sol`
  Pure protocol risk math:
  - collateral valuation
  - max borrow calculation
  - LTV calculation
  - liquidation sizing

### `src/core/ICFT/lending`

- `InterestRateModel.sol`
  Borrow APR curve driven by utilization buckets.

- `LendingPool.sol`
  Main stateful protocol contract:
  - accepts collateral
  - opens debt
  - accrues interest
  - processes repayments
  - handles pool-level liquidation settlement

- `LiquidationEngine.sol`
  Restricted helper for liquidation operators.
  Wraps pool liquidation with preview + settlement forwarding.

### `src/core/interfaces`

Canonical protocol interfaces for integrations, testing, and ABI stability.

- `IPriceOracle.sol`
- `IRiskEngine.sol`
- `IInterestRateModel.sol`
- `ILendingPool.sol`
- `ILiquidationEngine.sol`

### `src/core/utils`

- `Errors.sol`
  Shared custom errors used across the protocol.

- `PriceSource.sol`
  Enum describing ICFT pricing source selection.

### `src/mocks`

- `MockChainlinkFeed.sol`
  Local testing feed used in unit and integration tests.

### `test`

Testing layers:

- direct behavior tests
- fuzz tests
- invariant tests
- shared fixtures

Main files:

- `ICFTProtocol.t.sol`
- `ICFTProtocolFuzz.t.sol`
- `PriceOracle.t.sol`
- `RiskAndRateModel.t.sol`
- `helpers/ProtocolFixture.sol`
- `invariants/ICFTProtocolInvariants.t.sol`

### `script`

- `DeployICFTProtocol.s.sol`
  Foundry deployment script intended for local deployment and controlled experimentation.

### `docs`

- `MVP_SPEC.md`
  Functional target for the MVP baseline.

- `GAP_ANALYSIS.md`
  Gaps between protocol expectations and implementation state.

- `DEPLOYMENT.md`
  Localhost-first deployment runbook.

## Core Architecture

### 1. Token Layer

`ICFT.sol` is a simple fixed-supply token.

It does not contain lending logic.
It only defines supply and allocation.

### 2. Oracle Layer

`PriceOracle.sol` provides normalized prices.

The normalization target is always `1e18`, so every core module can calculate with one shared precision model.

This is why protocol math talks about `USD`, even though no stablecoin is present.

### 3. Risk Layer

`RiskEngine.sol` is responsible for protocol safety math.

It answers:

- how much collateral is worth
- how much can be borrowed
- whether a position is liquidatable
- how large a liquidation slice should be

### 4. Rate Layer

`InterestRateModel.sol` decides borrow APR from utilization.

It does not mutate pool state.
It only returns the current rate bucket.

### 5. Pool Layer

`LendingPool.sol` is the protocol core.

It owns:

- user positions
- collateral balances
- debt balances
- interest accrual
- Fund A liquidity accounting
- protocol revenue accounting

This is the most important contract in the repository.

### 6. Liquidation Helper Layer

`LiquidationEngine.sol` exists because the MVP uses a restricted liquidation operator flow.

Instead of exposing a broad permissionless liquidation path, the helper:

- previews a liquidation
- pulls ICFT from the operator
- calls the pool liquidation
- forwards seized ETH
- returns unused ICFT if needed

## Accounting Model

The most important architectural point:

- collateral is `ETH`
- borrowed asset is `ICFT`
- debt accounting unit is internal `USD`

That means:

- users do **not** borrow `USDC`
- users do **not** borrow `USDT`
- users do **not** repay a stablecoin

They borrow and repay `ICFT`, while the protocol measures risk and debt value in normalized dollar terms.

## Fund A Accounting

The pool keeps separate aggregate buckets:

- `fundALiquidityICFT`
- `totalBorrowedICFT`
- `totalPrincipalDebtUSD`
- `totalAccruedInterestUSD`
- `protocolRevenueICFT`

These buckets exist so the MVP can distinguish:

- principal liquidity
- borrowed inventory
- principal debt
- accrued interest
- protocol-owned revenue

This is still only an MVP approximation, not a treasury-grade accounting system.

## Why This Is Localhost-Only

This snapshot still depends on assumptions that are acceptable for local development but weak for public deployment:

- manual ICFT price support
- restricted liquidation operator model
- simplified collateral seizure flow
- no governance hardening
- no full operational playbook
- no production observability
- incomplete economic validation

So the recommended workflow is:

1. run `anvil`
2. fill `.env`
3. deploy locally
4. run tests
5. inspect behavior
6. keep iterating

## Recommended Files To Commit

Safe and expected to commit:

- `src/`
- `test/`
- `script/`
- `docs/`
- `README.md`
- `CODE_README.md`
- `LICENSE`
- `foundry.toml`
- `package.json`
- `package-lock.json`
- `.env.example`

Usually do **not** commit:

- `.env`
- `cache/`
- `out/`
- local `broadcast/31337/`
- `node_modules/`
- `lib/` if your team restores dependencies externally
- private business docs inside `ICFT_PROTOCOL_DOCS/`

## License

This repository is licensed under `GPL-3.0-only`.

See:

- `LICENSE`
- SPDX headers in the Solidity source files
