# ICFT MVP Gap Analysis

## Status

Date of original review: August 23, 2026

Scope reviewed against:

- `docs/MVP_SPEC.md`
- current Solidity code in `src/`
- current tests in `test/`

Bottom line at the time of the original review:

- the repo currently contains a useful prototype skeleton;
- it does not yet satisfy the canonical definition of a complete ICFT MVP.

## Update Note

This document reflects the repo state at the time of the original MVP gap review.

Since then, the repository has materially improved:

- `LiquidationEngine` is no longer a placeholder;
- upgradeable deployment and upgrade scripts now exist;
- fuzz and invariant tests now exist;
- multi-collateral support for `ETH`, `wBTC`, and `wstETH` now exists;
- the historical utilization-based accrual mispricing issue has been addressed with a borrow-index accounting model;
- the protocol has been exercised on Sepolia as an early upgradeable testnet baseline.

Remaining gaps should therefore be read together with:

- `docs/TESTNET_BASELINE.md`
- `docs/DEPLOYMENT.md`
- `docs/UPGRADES.md`

## What Already Exists

### Implemented

- Fixed-supply `ICFT` ERC-20 token.
- `PriceOracle` with Chainlink ETH/USD and manual ICFT/USD.
- `InterestRateModel` with configurable curve.
- `RiskEngine` with LTV and partial liquidation math.
- `LendingPool` with deposit, withdraw, borrow, repay, and restricted liquidation.
- Basic Forge tests.
- Basic README.

### Missing or Incomplete

- No deployment scripts.
- No integration environment beyond one local test file.
- No fuzz tests.
- No invariant tests.
- Placeholder `LiquidationEngine.sol`.
- No real config/deployment pipeline for testnets.
- No full protocol documentation/runbook.

## Contract-by-Contract Findings

### `src/core/ICFT/token/ICFT.sol`

Current state:

- fixed supply and one-time allocation are present.

Gaps:

- no vesting or release mechanics for non-circulating allocations;
- no formal Fund A vault or treasury separation at the contract level;
- no explicit accounting hooks for Fund A replenishment, treasury revenue, or future migration;
- tokenomics are only valid if `v10` allocation is accepted as canonical.

Assessment:

- acceptable as a temporary MVP token base;
- not sufficient as the final token layer for the full repo scope.

### `src/core/ICFT/oracle/PriceOracle.sol`

Current state:

- valid Chainlink ETH/USD integration;
- manual ICFT/USD price source;
- stale and invalid answer checks;
- `1e18` normalization.

Gaps:

- no update throttling or delta guardrails for manual price changes;
- no multi-role/admin split beyond AccessControl;
- no oracle source migration playbook;
- no dedicated tests yet for stale, zero, and negative feed cases.

Assessment:

- a good MVP start;
- still operationally risky because manual ICFT pricing is powerful and under-tested.

### `src/core/ICFT/lending/InterestRateModel.sol`

Current state:

- configurable utilization curve exists.

Gaps:

- the curve exists in isolation and is not connected to a richer economic accounting model;
- no tests around boundary transitions and borrow-disable threshold;
- documentation says Risk Engine may own parameterization later, but no integration contract exists for that governance path.

Assessment:

- structurally fine for MVP;
- test coverage and system integration are not sufficient.

### `src/core/ICFT/risk/RiskEngine.sol`

Current state:

- collateral valuation;
- LTV math;
- liquidation threshold;
- target post-liquidation LTV;
- liquidation sizing.

Gaps:

- liquidation math is not yet proven by fuzzing/invariants;
- no link to real market liquidity constraints despite whitepaper concerns;
- no dedicated support for different liquidation settlement backends;
- no penalty/bonus accounting destination beyond raw output values.

Assessment:

- mathematically plausible;
- not yet hardened enough for a serious lending MVP.

### `src/core/ICFT/lending/LendingPool.sol`

Current state:

- ETH deposit;
- ETH withdrawal;
- ICFT borrow;
- ICFT repay;
- restricted liquidation;
- pause and roles;
- lazy interest accrual.

Major gaps:

- Fund A accounting is incomplete:
  - no explicit `totalBorrowedICFT`;
  - no explicit `availableFundA`;
  - no separation between principal inventory and protocol revenue;
  - utilization relies on pool token balance rather than a full economic state model.
- `receive()` accepts raw ETH without user accounting path.
- no direct liquidation settlement abstraction;
- no event coverage for all operational transitions expected by indexing and administration;
- no explicit protocol revenue accounting from interest;
- no explicit bad debt or residual collateral policy;
- no emergency freeze matrix beyond simple pause/unpause;
- no testnet admin configuration wrapper.

Assessment:

- currently the main blocker to calling the system a complete MVP.

### `src/core/ICFT/lending/LiquidationEngine.sol`

Current state:

- placeholder only.

Assessment:

- direct failure against canonical MVP completion criteria.

## Testing Gaps

Current tests cover only:

- oracle normalization;
- one borrow/repay path;
- one withdraw health check;
- one pause scenario;
- one liquidation scenario.

Missing tests:

- stale ETH oracle;
- zero/negative ETH oracle;
- manual ICFT price authorization;
- interest accrual across time;
- partial repay rounding;
- repeated borrow/repay cycles;
- utilization boundary tests;
- borrow-disable at `90%+`;
- insufficient liquidity with liquidity buffer;
- repeated liquidation edge cases;
- unauthorized role operations;
- ETH transfer failure path;
- fuzzing for amounts, prices, timestamps, and ratios;
- invariants for solvency and accounting.

Assessment:

- the current suite is a smoke test suite, not a protocol validation suite.

## Documentation Gaps

Missing repo-local documents:

- canonical lifecycle specification before `docs/MVP_SPEC.md`;
- admin runbook;
- deployment configuration guide;
- oracle operations guide;
- liquidation operations guide;
- test matrix document;
- known-risk register.

## Source Conflicts That Must Stay Explicit

### Tokenomics Conflict

`ICFT_White_Paper_v10_RU_Investor.html` and the chat brief align on:

- `150m LP`
- `280m Strategic Reserve`
- `30m Ecosystem`

`Tockenomics_ICFT.html` presents a conflicting reserve split, including:

- `400m Reserve`
- `40m Liquidity`
- `20m Ecosystem`

Decision:

- use `v10` plus the chat brief as canonical for current MVP.

### Economic Scope Conflict

Older docs include:

- USDT collateral;
- direct USDT repayment;
- stabilization funds;
- emergency market interventions;
- burn-linked flows.

The current MVP brief excludes those from core implementation.

Decision:

- treat them as future roadmap items, not current MVP acceptance criteria.

## Required Next Implementation Phase

The next phase should no longer be treated as "add a few missing features."

It should be treated as a **testnet-baseline refactor** with three goals:

1. move stateful contracts to upgradeable deployments;
2. replace the current simplistic debt accrual with a more correct index-based model;
3. add deployment, admin, and testing discipline suitable for repeated public testnet releases.

### Newly Confirmed Economic Flaw

The current lending pool accrual logic applies the latest utilization-based APR when interest is accrued after time has already elapsed.

This can overcharge or undercharge for earlier sub-periods because the protocol does not maintain a proper borrow index history.

Implication:

- the localhost prototype is still useful;
- the protocol should not be promoted to public testnet without fixing this accounting path.

To move this repo from prototype to complete MVP, the next phase must deliver:

1. Full Fund A accounting redesign.
2. Explicit borrowed-liquidity and protocol-revenue accounting.
3. Non-placeholder liquidation execution architecture.
4. Wider event surface and admin/config ergonomics.
5. Full unit, integration, fuzz, and invariant coverage.
6. Deployment scripts and testnet config.
7. Updated documentation matched to the final code.

## Recommended Build Order

1. Refactor `LendingPool` accounting model.
2. Finalize liquidation architecture and remove placeholder engine.
3. Add protocol configuration structs and deployment scripts.
4. Expand tests to unit + integration.
5. Add fuzz and invariant suites.
6. Re-run review and fix uncovered accounting or security issues.

## Readiness Verdict

Current readiness: `prototype / partial MVP skeleton`

Not yet acceptable as:

- a fully working MVP protocol;
- a complete implementation of the canonical ICFT repo scope;
- a security-reviewed lending system.
