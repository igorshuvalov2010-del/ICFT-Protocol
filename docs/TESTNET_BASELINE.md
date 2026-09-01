# ICFT Testnet Baseline Target

## Purpose

This document defines the next engineering target after the localhost-only MVP.

The goal is not mainnet readiness.
The goal is to turn the repository into a safe and realistic **testnet baseline** that supports:

- proxy-based upgrades;
- multi-release iteration;
- stronger debt accounting;
- better operational documentation;
- better deployment discipline.

## Why the Localhost MVP Is Not Enough

The current MVP was useful for proving:

- multi-collateral flow across ETH, wBTC, and wstETH;
- ICFT borrowing and repayment;
- oracle normalization;
- basic liquidation flow;
- basic tests and deployment scripts.

However, it is still too early-stage for serious public testnet work because:

- upgrade paths are not yet documented end-to-end for operators;
- admin and upgrade operations are not yet fully hardened operationally;
- deployment flow still needs final operator-facing multi-collateral guidance;
- test coverage does not yet prove upgrade safety or long-lived accounting behavior over multiple releases.

As of September 1, 2026, the repository has crossed part of that boundary:

- the protocol has an upgradeable Sepolia deployment;
- the core multi-collateral basket now includes `ETH`, `wBTC`, and `wstETH`;
- the interest-accrual mispricing issue has been fixed with a borrow-index model;
- the test suite includes unit, integration, fuzz, invariant, and upgradeability checks.

What still keeps the system in an early testnet stage:

- `ICFT/USD` remains manually controlled;
- `wstETH` testnet support currently depends on a mock USD feed in the recommended repo flow;
- testnet `wBTC` may depend on a test token rather than a canonical wrapped BTC deployment;
- operator security is not yet formalized around multisig, key rotation, and incident procedures.

## Recently Closed High-Priority Issue

### Historical interest mispricing across utilization changes

Earlier MVP iterations could misprice elapsed time by applying a later utilization bucket to an older accrual interval.

The current codebase closes that specific issue by:

1. accruing globally before utilization-changing actions;
2. tracking scaled debt through a borrow index;
3. testing the old failure mode directly.

This fix improves correctness, but it does **not** by itself make the protocol economically complete or mainnet-safe.

## Testnet Baseline Requirements

### Upgradeability

The testnet baseline should use proxy deployments for stateful contracts that are expected to evolve.

Target:

- upgradeable token if token logic is expected to evolve;
- upgradeable oracle;
- upgradeable risk engine;
- upgradeable interest model;
- upgradeable lending pool;
- upgradeable liquidation engine;
- documented proxy admin ownership.

### Accrual Model

The pool should move from lazy per-position APR snapshots to a **global borrow index** model.

Target properties:

- global accrual is applied before utilization-changing actions;
- positions store scaled debt instead of mixing raw principal with ad hoc accrued interest;
- debt growth is proportional to time and the index path;
- repayment and liquidation interact with normalized debt values;
- aggregate accounting remains consistent with user-level accounting.

### Deployment and Operations

Testnet baseline must include:

- proxy-aware deployment scripts;
- initialization order documentation;
- role and admin ownership documentation;
- upgrade procedure documentation;
- environment variable guide for operators;
- post-deploy verification checklist.

### Testing

The testnet baseline must add or strengthen:

- accrual correctness tests across utilization changes;
- proxy initialization tests;
- role and admin tests;
- upgrade-safe storage assumptions;
- fuzzing around debt, collateral, and liquidation transitions;
- invariants for solvency and accounting consistency.

## Recommended Architecture Direction

### Proxy Pattern

Preferred default for this stage:

- OpenZeppelin transparent proxies with a dedicated `ProxyAdmin`.

Reason:

- simpler operator mental model;
- explicit separation between upgrade authority and protocol roles;
- good fit for multi-contract protocol deployments.

### Role Separation

At minimum, separate:

- upgrade admin;
- protocol admin;
- oracle manager;
- risk manager;
- pause guardian;
- liquidation operator.

### State Separation

The repo should distinguish clearly between:

- user debt accounting;
- pool liquidity accounting;
- protocol revenue accounting;
- upgrade/admin state.

## What This Stage Still Does Not Promise

Even after the testnet-baseline refactor, the repo should still **not** be described as:

- mainnet-ready;
- audit-complete;
- economically finalized;
- market-liquidity-complete;
- governance-complete.

It also should not be described as:

- oracle-finalized;
- collateral-finalized;
- operationally hardened.

This stage is the bridge between:

`localhost prototype -> durable public testnet iteration`

## Acceptance Signal

This repository can be considered ready for the next testnet phase only when:

1. upgradeable deployments work end-to-end;
2. interest accrual no longer misprices elapsed time after utilization changes;
3. tests prove the new accounting behavior;
4. docs explain deployment, upgrades, and operational limits clearly.
