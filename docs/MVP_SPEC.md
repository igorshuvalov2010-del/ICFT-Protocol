# ICFT Canonical MVP Spec

## Purpose

This document defines the canonical MVP scope for the ICFT protocol as of August 23, 2026.

Its purpose is to remove ambiguity between:

- the direct implementation brief provided in chat;
- `ICFT_PROTOCOL_DOCS/ICFT_White_Paper_v10_RU_Investor.html`;
- `ICFT_PROTOCOL_DOCS/Tockenomics_ICFT.html`;
- `ICFT_PROTOCOL_DOCS/ICFT_White_Paper_v4.html`.

This spec is the source of truth for code, tests, deployment, and future reviews.

## Source Priority

When documents conflict, use this priority order:

1. The direct implementation brief from the user conversation.
2. `ICFT_White_Paper_v10_RU_Investor.html`.
3. `Tockenomics_ICFT.html`.
4. `ICFT_White_Paper_v4.html`.

Rationale:

- The chat brief is the most explicit engineering scope.
- `v10_RU_Investor` is the most recent investor-oriented protocol description in the repo.
- `Tockenomics_ICFT.html` contains useful token allocation and reserve context, but it conflicts with `v10` on some allocation details and includes non-MVP economics.
- `v4` contains older USDT-collateral, USDT-repayment, emergency, and stabilization mechanics that are broader than the current ETH-collateral MVP brief.

## Canonical Product Definition

ICFT MVP is a testnet-only DeFi lending protocol where:

- users deposit ETH as collateral;
- users borrow ICFT;
- debt principal is denominated in USD, not ICFT units;
- repayment is made in ICFT based on the current ICFT/USD price;
- LTV and liquidation risk are enforced onchain;
- ETH/USD comes from Chainlink;
- ICFT/USD is manually controlled for MVP and must be replaceable later.

## Explicitly In Scope for MVP

### Token

- ERC-20 ICFT token.
- Fixed total supply: `1,000,000,000 ICFT`.
- No uncontrolled minting.
- One-time initial allocation according to canonical tokenomics below.
- OpenZeppelin ERC20 implementation.

### Canonical Token Allocation for MVP

Use the allocation described in the implementation brief and aligned with `v10_RU_Investor`:

- Fund A: `200,000,000 ICFT`
- Liquidity / LP: `150,000,000 ICFT`
- Strategic Reserve: `280,000,000 ICFT`
- Future Investors: `160,000,000 ICFT`
- Founder: `80,000,000 ICFT`
- Developers: `100,000,000 ICFT`
- Ecosystem / Grants: `30,000,000 ICFT`

Total:

- `1,000,000,000 ICFT`

### Lending Core

- ETH collateral only.
- Deposit collateral.
- Withdraw collateral.
- Borrow ICFT.
- Repay debt in ICFT.
- USD-denominated debt principal.
- USD-denominated interest accrual.
- Fund A accounting.
- Utilization calculation.
- Configurable liquidity buffer.

### Oracle System

- Chainlink ETH/USD feed.
- Manual/admin ICFT/USD price for MVP.
- Future-compatible architecture for swapping ICFT/USD to Chainlink or another trusted oracle.
- Decimal normalization to `1e18`.
- Stale answer protection.
- Zero/negative answer protection.
- Invalid feed protection.

### Risk and Liquidation

- Max LTV: configurable, default canonical value `80%`.
- Liquidation threshold: configurable, default canonical value `90%`.
- Target post-liquidation LTV: configurable, default canonical value `85%`.
- Partial liquidation.
- Contract-calculated liquidation conditions and liquidation size.
- Restricted liquidation executor or bot is acceptable for MVP.
- Smart contract must not trust offchain liquidation calculations.

### Interest Model

- Utilization-based dynamic APR.
- Default curve from implementation brief:
  - `0-50%`: `5% APR`
  - `50-80%`: `8% APR`
  - `80-90%`: `15% APR`
  - `90%+`: `20% APR`
- New borrowing disabled at `90%+` utilization.
- Rates and thresholds configurable.

### Controls and Safety

- Access control.
- Emergency pause/freeze for risk-sensitive state changes.
- Repayment allowed during pause unless a specific future reason requires otherwise.
- Reentrancy protection.
- Checks-effects-interactions for ETH transfers.

### Tests

MVP must include:

- unit tests;
- integration tests;
- fuzz tests for critical accounting;
- invariant tests for protocol safety properties.

### DevOps

- deployment scripts;
- testnet deployment configuration;
- documentation.

## Explicitly Out of Scope for This MVP

- Bitcoin collateral.
- Multiple collateral assets.
- Cross-chain support.
- Protocol-owned DEX implementation.
- DAO/governance mechanics as a live control plane.
- Complex routing.
- Programmable loans.
- Mainnet-ready stabilization system.
- Mainnet-ready proxy architecture.

## Canonical Economic Rules

### Debt Denomination

Debt principal is stored in USD value at borrow time.

Example:

- If ICFT = `$1`, borrowing `50,000 ICFT` creates `50,000 USD` principal.
- If ICFT later = `$2`, repayment of principal requires `25,000 ICFT`.
- If ICFT later = `$0.50`, repayment of principal requires `100,000 ICFT`.

### Interest Denomination

- Interest accrues in USD.
- Interest is computed against USD principal.
- Repayment converts the USD obligation into ICFT at the current ICFT/USD price.

### Fund A

Fund A is the protocol lending inventory.

The protocol must track:

- total Fund A allocation;
- total currently borrowed ICFT;
- available ICFT liquidity;
- utilization.

Canonical utilization target for implementation:

- primary accounting metric: `borrowed ICFT / Fund A allocation`;
- secondary operational checks may additionally consider actual liquid pool inventory and configured liquidity buffer.

Note:

- The whitepaper also ties lending capacity to real market liquidity.
- MVP should at minimum expose risk hooks or config points for future market-liquidity-aware controls.

## Canonical Liquidation Model for MVP

The MVP does not need a full permissionless DEX liquidation pipeline.

However, it must model liquidation honestly:

- a liquidation executor or bot performs settlement;
- the contract independently validates eligibility and liquidation amount;
- the executor covers the USD debt reduction economically;
- seized ETH must be explicitly accounted for;
- the architecture must be extendable to future DEX or external settlement integrations.

Important:

- The contract must not pretend that USDT appears automatically.
- The contract must not silently assume real market execution if no swap path exists.

## Handling Whitepaper Features That Are Not In MVP Core

The following topics appear in repo documents but are not canonical MVP requirements unless reintroduced later:

- buyback & burn as live protocol logic;
- direct USDT repayment path;
- USDT collateral model from older docs;
- stabilization fund;
- insurance fund;
- emergency market intervention logic;
- DAO-governed mint or emissions;
- production LP incentives.

These may inform future roadmap work, but they are not required for the current MVP implementation pass.

## Canonical Deliverables Required Before MVP Is Considered Complete

The repo must contain:

- complete lending core contracts;
- complete oracle, risk, and interest modules;
- non-placeholder liquidation architecture;
- deployment scripts and configuration;
- documentation for lifecycle, assumptions, and limitations;
- unit tests;
- integration tests;
- fuzz tests;
- invariants;
- successful `forge build` and `forge test`.

## Completion Criteria

The ICFT MVP is only considered complete when:

1. every in-scope feature above exists in code;
2. the implementation matches the canonical economic rules;
3. the repo contains the required deployment and testing artifacts;
4. the remaining limitations are explicitly documented as testnet-only;
5. a review against this document finds no placeholder modules in the execution path.
