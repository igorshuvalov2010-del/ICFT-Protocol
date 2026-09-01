# ICFT

> Programmable Credit Infrastructure for Crypto

This repository is currently an **earliest-stage upgradeable testnet baseline** for the ICFT protocol implementation.

The protocol now runs as a proxy-based Sepolia deployment for engineering validation, but it is still far from production-ready. See `docs/TESTNET_BASELINE.md`.

Important:

- do not use this code with real funds
- do not treat this repository as mainnet-ready
- do not treat this repository as production-ready
- use it on `localhost` / `anvil` and carefully controlled public testnets for development, testing, and architecture iteration

This repository is licensed under `GPL-3.0-only`. See `LICENSE`.

ICFT is a decentralized crypto-credit protocol that allows users to access liquidity by using crypto assets as collateral instead of selling them.

Users can deposit supported assets such as ETH, wBTC, and wstETH, borrow ICFT against their collateral, and exchange the borrowed ICFT for USDT or other supported assets through decentralized liquidity markets.

For the current implementation status and code architecture, also read:

- `CODE_README.md`
- `docs/MVP_SPEC.md`
- `docs/GAP_ANALYSIS.md`
- `docs/DEPLOYMENT.md`
- `docs/TESTNET_BASELINE.md`
- `docs/UPGRADES.md`

## The Problem

Crypto holders often need liquidity without wanting to sell assets they believe will increase in value.

For example, a user holding ETH may need USDT but may not want to sell their ETH and lose exposure to its future price movement.

ICFT provides an alternative:

**Crypto Collateral → ICFT Credit → Liquidity**

The user can use their crypto as collateral, access liquidity through ICFT, and later repay the loan to unlock their collateral.

## How It Works

1. The user deposits supported crypto assets as collateral.
2. The protocol evaluates the collateral using decentralized price data and predefined risk parameters.
3. The user borrows ICFT within their permitted Loan-to-Value (LTV).
4. The borrowed ICFT can be exchanged for USDT or other supported assets.
5. The user repays the outstanding ICFT debt.
6. Once the debt is repaid, the user can withdraw their collateral.

**Example:**

ETH / wBTC / wstETH collateral → ICFT loan → ICFT/USDT → USDT liquidity → Repay ICFT → Withdraw collateral

## Core Features

### Collateralized Lending

Users can borrow ICFT against supported crypto assets without directly selling their collateral.

### Risk Management

The protocol uses LTV, liquidation thresholds, collateral parameters, and decentralized price data to monitor borrowing positions.

### Automated Liquidation

If a position becomes undercollateralized, the protocol can automatically liquidate part or all of the required collateral according to predefined rules.

### Decentralized Liquidity

ICFT can be traded through liquidity markets such as ICFT/USDT and, as the protocol develops, ICFT/ETH and other pairs.

### Programmable Loan Automation

A future version of ICFT is planned to allow users to configure automated rules for managing their borrowing positions.

For example:

**If LTV reaches 60% → automatically reduce part of the debt.**

**If LTV reaches the liquidation threshold → execute the protocol's liquidation mechanism.**

These strategies operate within the global risk limits enforced by the protocol.

### Non-Custodial

Users interact directly with smart contracts through compatible Web3 wallets rather than depositing their assets into centralized custody.

## Architecture

The initial ICFT architecture consists of several core components:

- Collateral Vault
- Lending Pool
- Risk Engine
- Oracle System
- Liquidation Engine
- ICFT Token
- Liquidity Markets
- Emergency Controls

The architecture is designed to remain modular so individual components can be tested, improved, and audited independently.

## ICFT Token

ICFT is the native credit and ecosystem asset of the protocol.

**Total Supply:** 1,000,000,000 ICFT

**Initial Reference Price:** $0.50

ICFT is designed to have utility within the protocol through lending, borrowing, liquidity incentives, trading, governance, and future ecosystem functionality.

The detailed token allocation, vesting, and economic model are described in the project's tokenomics documentation.

## Liquidity

Liquidity is a critical component of the ICFT ecosystem.

The initial liquidity strategy can combine protocol-controlled ICFT reserves with external liquidity providers.

For example:

**Protocol ICFT + External USDT → ICFT/USDT Liquidity Pool**

Liquidity providers may receive trading fees and ICFT-based incentives according to the protocol's liquidity model.

As the protocol grows, the objective is to develop deeper and increasingly organic liquidity.

## Security

Security is a fundamental requirement of ICFT.

The protocol is designed around:

- Smart-contract-enforced risk parameters
- LTV limits
- Oracle-based collateral valuation
- Automated liquidation
- Access control
- Emergency pause mechanisms
- Automated testing
- Testnet deployment
- Security reviews and audits before production deployment

ICFT is an experimental DeFi protocol under active development. Smart contracts and economic mechanisms will be thoroughly tested before any production deployment.

## Roadmap

### Phase 1 — Lending MVP

- ICFT ERC-20
- Collateral Vault
- Lending Pool
- ETH, wBTC, and wstETH collateral
- LTV calculation
- Interest calculation
- Borrowing and repayment
- Collateral withdrawal
- Oracle integration
- Liquidation mechanism
- Emergency Freeze
- Basic frontend
- Wallet integration
- Testnet deployment
- Automated tests

### Phase 2 — Liquidity & Expansion

- ICFT/USDT liquidity
- Additional collateral assets beyond ETH, wBTC, and wstETH
- Additional ICFT markets
- Improved liquidation mechanisms
- Liquidity incentives
- Advanced risk management

### Phase 3 — Programmable Credit

- Programmable loan parameters
- Automated debt management
- Automated collateral management
- Self-healing positions
- Advanced credit strategies
- Additional DeFi integrations

### Phase 4 — Financial Infrastructure

- Integrated DEX
- Advanced liquidity routing
- Developer SDK
- Third-party integrations
- Institutional credit infrastructure
- Additional financial primitives

## Technology

ICFT is being developed for EVM-compatible blockchain infrastructure.

The initial technology stack includes:

- Solidity
- EVM-compatible smart contracts
- ERC-20
- Decentralized oracle infrastructure
- Web3 wallets
- Decentralized liquidity
- Automated testing

## Project Status

ICFT is currently in the early development stage.

As of September 1, 2026, the immediate goal is to harden the newly deployed upgradeable Sepolia baseline and continue moving from MVP behavior toward a more realistic public-testnet protocol iteration.

The code in this repository represents the **very first practical upgradeable testnet stage** and should currently be used only on local development chains and controlled public testnets.

Development follows an incremental approach:

**Localhost MVP → Upgradeable Testnet Baseline → Testnet Hardening → Security Testing → Liquidity → Mainnet Preparation → Programmable Credit → Financial Infrastructure**

## Current Testnet Status

As of September 1, 2026, the repository includes an upgradeable Sepolia baseline with:

- transparent proxies for all core protocol modules;
- onchain support for `ETH`, `wBTC`, and `wstETH` collateral registration;
- index-based debt accrual that avoids repricing old elapsed time with a later utilization bucket;
- unit, integration, fuzz, invariant, and upgrade-path tests;
- deployment and upgrade runbooks for repeated public-testnet iteration.

Current important limitations:

- `ICFT/USD` is still manually administered for MVP and early testnet usage;
- `wstETH` on Sepolia currently relies on a testnet-only mock USD feed in this repo's recommended flow;
- `wBTC` on Sepolia may rely on a test token rather than a canonical production-grade wrapped BTC deployment;
- admin and upgrade operations are still managed as an engineering workflow, not a finalized multisig/governance process.

Before any production deployment, these pieces must be replaced with production-grade operational controls, oracle sources, custody assumptions, and audited governance.

## Contributing

ICFT is an open development project.

Developers, researchers, security specialists, economists, and Web3 contributors are welcome to participate.

Contributions can include:

- Solidity development
- Smart-contract architecture
- Frontend development
- Testing
- Security research
- Risk modeling
- Economic research
- Documentation
- Developer tooling

## Disclaimer

ICFT is an experimental decentralized finance project under development.

The protocol, smart contracts, tokenomics, risk parameters, supported assets, and planned functionality may change during development.

Nothing in this repository constitutes financial, investment, legal, or tax advice.

DeFi protocols involve significant technical, economic, market, smart-contract, oracle, and liquidation risks.

## Vision

ICFT aims to evolve from a decentralized crypto lending protocol into programmable credit infrastructure for the broader crypto ecosystem.

The long-term vision is to allow users and developers to use crypto collateral, access liquidity, automate credit positions, and build new financial applications on top of open protocol infrastructure.

**ICFT — Programmable Credit Infrastructure for Crypto.**
