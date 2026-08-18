# ICFT

> Programmable Credit Infrastructure for Crypto

ICFT is a decentralized crypto-credit protocol designed to transform crypto collateral into flexible, automated, and programmable liquidity.

The protocol allows users to deposit supported crypto assets as collateral and borrow ICFT against their collateral. Borrowed ICFT can then be exchanged for USDT or other supported crypto assets through decentralized liquidity markets.

The core idea is to provide liquidity without requiring users to sell crypto assets they already own.

For example, a user may hold ETH because they believe its value will increase over time. Selling ETH would provide liquidity, but it would also reduce the user's exposure to ETH. With ICFT, the user can deposit ETH as collateral, borrow ICFT against it, exchange the borrowed ICFT for USDT or another supported asset, use the obtained liquidity, and later acquire ICFT to repay the loan and unlock the collateral.

ICFT initially focuses on decentralized crypto lending and is designed to evolve into broader programmable financial infrastructure.

---

## The Problem

Crypto holders often face a fundamental trade-off between maintaining exposure to their assets and obtaining liquidity.

A user may hold BTC, ETH, SOL, or another crypto asset while simultaneously needing liquidity.

The traditional solution is to sell the asset:

Crypto asset → Sell → USDT → Liquidity

However, selling the asset means losing exposure to its future price movement.

Crypto lending provides another option:

Crypto asset → Collateral → Credit → Liquidity

ICFT is designed around this second model.

Instead of selling an asset, users can use it as collateral to access liquidity while maintaining ownership of the underlying asset as long as the borrowing position remains healthy.

---

## How ICFT Works

The basic ICFT lending process is:

Crypto Collateral → Collateral Vault → Risk Assessment → ICFT Credit → ICFT/USDT or other market → Liquidity → Repayment → Collateral Withdrawal

A user deposits a supported crypto asset into the protocol.

The protocol evaluates the collateral using decentralized price data and predefined risk parameters.

The user can then borrow ICFT within the permitted borrowing limit.

The borrowed ICFT can be exchanged for USDT, ETH, BTC, or other supported assets through available liquidity markets.

When the user wants to close the position, they acquire the required amount of ICFT and repay the outstanding debt.

Once the debt and applicable fees have been repaid, the collateral becomes available for withdrawal.

---

## Why ICFT?

ICFT is designed around a simple principle:

> Users should be able to access liquidity without being forced to sell crypto assets they believe will appreciate.

The protocol combines:

- Crypto-backed lending
- Automated risk management
- Automated liquidation
- Decentralized liquidity
- Programmable loan management
- Non-custodial asset management
- Modular DeFi infrastructure

The initial product is lending.

The long-term objective is to develop a programmable credit infrastructure layer that can support additional financial applications.

---

## Core Architecture

The ICFT protocol is composed of several interconnected components:

- Collateral Vault
- Lending Pool
- Risk Engine
- Oracle System
- Liquidation Engine
- Liquidity Markets
- ICFT Token
- Emergency Controls
- Programmable Loan Automation Layer

Each component has a specific role in the protocol.

The architecture is designed to remain modular so that individual components can be developed, tested, upgraded, and audited independently.

---

## Collateral

ICFT is designed to support liquid crypto assets as collateral.

Potential collateral assets include:

- ETH
- BTC representations compatible with the selected EVM environment
- SOL representations compatible with the selected EVM environment
- Stablecoins
- Other liquid crypto assets
- Potentially tokenized real-world assets in future versions

Each collateral asset can have its own risk parameters.

For example, highly liquid and established assets can have different borrowing limits and liquidation thresholds compared with more volatile or less liquid assets.

The protocol does not need to treat every asset equally.

---

## Collateral Vault

The Collateral Vault is responsible for managing user collateral positions.

It handles:

- Collateral deposits
- Collateral balances
- User positions
- Withdrawal restrictions
- Collateral-to-debt relationships
- Interaction with the liquidation mechanism

A simplified structure is:

User Wallet → Collateral Vault → User Position → Risk Engine

While a borrowing position is active, the corresponding collateral remains locked by the protocol's smart contracts.

---

## Lending Pool

The Lending Pool represents the core credit and liquidity layer of the protocol.

It manages the mechanisms required for borrowing and repayment and can interact with:

- Borrower positions
- Liquidity providers
- Protocol reserves
- Interest accounting
- Risk parameters
- Liquidation mechanisms

The exact capital utilization and pool architecture may evolve during development and testing.

---

## Loan-to-Value (LTV)

LTV is one of the primary risk parameters used by ICFT.

LTV represents the relationship between the user's debt and the value of their collateral.

LTV = Debt / Collateral Value × 100%

For example:

Collateral Value: $100,000

Debt: $50,000

LTV: 50%

If the collateral decreases in value while the debt remains unchanged, the LTV increases.

For example:

Collateral Value: $80,000

Debt: $50,000

LTV: 62.5%

This allows the protocol to continuously evaluate the risk of a borrowing position.

---

## Borrowing

Once collateral has been deposited, the protocol determines the user's borrowing capacity.

For example:

Collateral Value: $100,000

Maximum LTV: 60%

Maximum Borrowing Capacity: $60,000

The user does not have to borrow the maximum amount.

They could instead borrow:

$40,000 ICFT

This would initially create an LTV of:

40%

Borrowing capacity can differ between collateral assets according to protocol-defined risk parameters.

---

## ICFT as the Credit Asset

ICFT is the native credit asset of the initial protocol.

Users borrow ICFT against crypto collateral.

The borrowed ICFT can then be exchanged through supported liquidity markets.

For example:

ETH Collateral → ICFT Loan → ICFT/USDT → USDT

Or potentially:

ETH Collateral → ICFT Loan → ICFT/ETH → ETH

This creates a direct relationship between the lending mechanism and the utility of the ICFT token.

The objective is for ICFT demand to originate from actual protocol usage rather than relying solely on speculative demand.

---

## Repayment

To close a borrowing position, the user must repay the outstanding ICFT debt and applicable fees.

The basic process is:

User acquires ICFT → Repays debt → Debt becomes zero → Collateral becomes withdrawable

The user can repay the position before the liquidation threshold is reached.

---

## Interest

Borrowing may accrue interest according to the protocol's interest-rate model.

A user's outstanding debt can therefore be represented as:

Principal + Accrued Interest = Outstanding Debt

The interest model may depend on factors such as pool utilization and available liquidity.

The final interest-rate mechanism will be defined and tested during protocol development.

---

## Health Factor

ICFT can use a Health Factor to represent the safety of a borrowing position.

A simplified representation is:

Health Factor > 1 — Safe

Health Factor ≈ 1 — Critical

Health Factor < 1 — Liquidatable

The exact formula can depend on:

- Collateral value
- Debt value
- Liquidation threshold
- Asset-specific risk parameters
- Other protocol-defined factors

The Health Factor provides a simple way for users and automated systems to understand the current state of a position.

---

## Risk Engine

The Risk Engine is responsible for evaluating borrowing positions.

It can calculate and monitor:

- Collateral value
- Debt value
- LTV
- Health Factor
- Borrowing capacity
- Liquidation thresholds
- Asset-specific risk parameters
- Market conditions
- Liquidity conditions

The Risk Engine operates according to predefined protocol rules.

For example:

ETH Maximum LTV: 70%

Liquidation Threshold: 80%

User LTV: 54%

Position: SAFE

If the value of the collateral decreases:

User LTV: 79%

Position: HIGH RISK

If the liquidation threshold is reached:

User LTV: 80%

Position: LIQUIDATABLE

---

## Oracle System

Accurate asset valuation is essential to a collateralized lending protocol.

ICFT therefore requires reliable decentralized price data.

The Oracle System can provide:

- Asset prices
- Price updates
- Deviation protection
- Stale-price protection
- Market data required by the Risk Engine

Oracle data is used to determine:

- Collateral value
- LTV
- Health Factor
- Borrowing capacity
- Liquidation eligibility

Oracle security is one of the critical components of the protocol.

---

## Automated Liquidation

Borrowing positions can become unsafe when the value of their collateral falls.

When a position reaches the liquidation threshold, the protocol can automatically initiate liquidation.

For example:

Collateral: $100,000

Debt: $50,000

LTV: 50%

If collateral falls to:

$62,500

while the debt remains:

$50,000

the LTV becomes:

80%

If 80% is the liquidation threshold, the position becomes eligible for liquidation.

The liquidation mechanism can:

1. Detect an unsafe position.
2. Determine the amount of collateral that needs to be liquidated.
3. Execute the liquidation.
4. Exchange collateral for the required debt asset.
5. Repay the outstanding debt.
6. Return remaining collateral to the user where applicable.

The protocol can use partial liquidation instead of automatically liquidating the entire position.

This allows the system to attempt to restore the position to a safer level while minimizing unnecessary collateral sales.

---

## Liquidation Keepers

Blockchain smart contracts cannot initiate transactions by themselves.

Therefore, ICFT can use external keepers or automated transaction executors to trigger liquidation functions.

The keeper does not decide whether a position is liquidatable.

Instead:

Keeper → Calls liquidation function → Smart Contract verifies conditions → Liquidation executes if conditions are satisfied

The smart contract remains responsible for enforcing the actual liquidation rules.

This prevents an external keeper from arbitrarily liquidating healthy positions.

---

## Liquidation Incentives

Liquidators can receive a predefined incentive for successfully executing liquidations.

The purpose is to create an economic reason for external participants to monitor the protocol and execute liquidations when positions become unsafe.

The exact liquidation incentive will depend on the protocol's risk model.

---

## Partial Liquidation

ICFT can use partial liquidation to reduce unnecessary collateral sales.

Instead of:

Unsafe Position → Sell Everything

the protocol can operate as:

Unsafe Position → Sell Part of Collateral → Repay Part of Debt → Restore Safer LTV

For example:

Initial LTV: 82%

Partial liquidation:

Collateral decreases

Debt decreases

LTV returns below the liquidation threshold

The remaining position stays active.

This can reduce unnecessary losses for borrowers while helping protect the protocol.

---

## Emergency Freeze

ICFT includes an Emergency Freeze mechanism designed to protect the protocol during critical events.

Potential emergency situations include:

- Oracle failure
- Smart-contract vulnerability
- Abnormal market conditions
- Price manipulation
- Unexpected protocol behavior
- Critical security incidents

The emergency mechanism can temporarily restrict selected protocol functions while the situation is investigated.

Emergency permissions should be strictly controlled and transparently managed.

---

## Programmable Loan Automation

A long-term direction of ICFT is to introduce an automated loan-management layer.

The goal is not simply to make borrowing programmable, but to allow users to define predefined rules for managing their own credit positions.

For example, a user could configure:

If LTV reaches 60% → automatically repay 10% of the debt.

If LTV reaches 65% → perform another predefined risk-management action.

If LTV reaches 70% → partially liquidate the position.

If the liquidation threshold is reached → protect the position according to the configured strategy or proceed with protocol liquidation rules.

The user would configure these rules through the ICFT application without needing to write Solidity code.

The smart contracts would then execute permitted actions automatically.

---

## Protocol Risk Limits

Programmability does not mean that users can force the protocol to take unlimited risk.

The protocol defines global safety boundaries.

For example:

Protocol Maximum LTV: 70%

A user cannot configure:

Maximum LTV: 95%

if 95% is outside the protocol's permitted risk parameters.

The system therefore has two layers:

Protocol Risk Limits → User Strategy → Smart Contract Execution

User-defined strategies operate only inside the safety boundaries established by the protocol.

---

## Self-Healing Positions

A future version of the programmable loan system can introduce self-healing positions.

Instead of waiting until a position becomes liquidatable, the protocol can react to deteriorating risk levels.

For example:

LTV 55% → Normal

LTV 60% → Warning

LTV 65% → Automatic Risk Action

LTV 70% → Partial Liquidation if required

The objective is to create positions that can automatically respond to market movements instead of requiring constant manual monitoring.

---

## Liquidity

Liquidity is essential for ICFT because borrowers need the ability to exchange borrowed ICFT for other assets.

Potential liquidity markets include:

- ICFT/USDT
- ICFT/ETH
- ICFT/BTC
- Other supported assets

The initial market is expected to focus on ICFT/USDT because USDT provides a widely used stable liquidity asset.

Additional pairs can be introduced as the protocol develops.

---

## Liquidity Providers

External liquidity providers can contribute assets to ICFT liquidity markets.

For example:

Liquidity Provider → USDT → ICFT/USDT Pool

The protocol can provide ICFT from its allocated reserves while external liquidity providers contribute USDT.

Liquidity providers can potentially receive:

- Trading fees
- ICFT liquidity incentives
- Other protocol-defined rewards

The purpose of the incentive system is to encourage early liquidity and create deeper markets for ICFT.

---

## Liquidity Bootstrapping

One of the main challenges of a new token is creating sufficient liquidity.

ICFT can initially address this through protocol-controlled ICFT reserves.

For example:

Protocol ICFT Reserves + External USDT Liquidity → ICFT/USDT Pool

This allows the protocol to create an initial market without requiring the protocol treasury to provide all liquidity assets itself.

As the protocol grows, the objective is to attract increasing amounts of organic external liquidity.

---

## ICFT Token

ICFT is the native token and credit asset of the protocol.

Total Supply:

1,000,000,000 ICFT

Initial Reference Price:

$0.50

The token is designed to have utility within the ICFT ecosystem.

Potential functions include:

- Lending and borrowing
- Liquidity incentives
- Trading
- Governance
- Protocol participation
- Potential staking mechanisms
- Future ecosystem functionality

The exact allocation, vesting, distribution, and utility structure are defined separately in the project's tokenomics.

---

## ICFT Economic Cycle

The long-term economic model is designed around actual protocol usage.

A simplified cycle is:

Crypto Collateral → ICFT Borrowing → ICFT Demand → Liquidity → Trading → Fees → Protocol Economics

Users need ICFT to use the lending system.

Liquidity providers enable ICFT markets.

Trading activity generates fees.

The protocol can distribute or allocate protocol revenue according to its economic model and governance structure.

The objective is to create sustainable utility around ICFT rather than relying exclusively on speculative demand.

---

## Protocol-Owned Liquidity

During the early stages of development, ICFT reserves may be used to bootstrap liquidity.

Protocol-owned ICFT can be paired with external USDT or other assets to establish initial markets.

This approach allows the protocol to use its existing ICFT allocation to help create the initial liquidity infrastructure.

Protocol-owned liquidity should be transparently managed and subject to predefined rules.

---

## Future Integrated DEX

As the protocol scales, ICFT can expand beyond lending and introduce its own decentralized exchange infrastructure.

The goal would be to allow users to perform the entire process inside a single application:

Deposit Collateral → Borrow ICFT → Exchange ICFT → Receive Asset

Instead of requiring the user to leave the ICFT ecosystem to access external liquidity.

Potential future markets could include:

- ICFT/USDT
- ICFT/ETH
- ICFT/BTC
- ICFT/SOL
- Other supported assets

A future DEX could also include:

- Liquidity aggregation
- Smart routing
- Multiple liquidity sources
- Reduced trading friction
- Native ICFT markets

The integrated exchange is a future expansion and is not required for the initial Lending MVP.

---

## Financial Infrastructure

The long-term vision of ICFT extends beyond lending.

The protocol can evolve into a broader crypto financial infrastructure layer combining:

Collateral

Credit

Liquidity

Trading

Risk Management

Programmable Loans

Payments

DeFi Integrations

Developer Infrastructure

The objective is to create an ecosystem where crypto assets can be used not only as investments, but as programmable financial resources.

---

## Developer Ecosystem

A long-term goal is to allow third-party developers to build applications on top of ICFT.

Potential developer interfaces could expose functionality such as:

depositCollateral()

withdrawCollateral()

borrow()

repay()

getCreditLimit()

getHealthFactor()

getCollateralValue()

getDebt()

liquidate()

Developers could eventually use ICFT infrastructure to create:

- Crypto credit applications
- Payment applications
- Trading applications
- Portfolio management tools
- Automated financial strategies
- Institutional products
- DeFi integrations

This would allow ICFT to evolve from a single lending application into an infrastructure layer for other applications.

---

## Security

Security is a fundamental requirement of ICFT.

The protocol is designed around:

- Modular smart contracts
- Access control
- Oracle protection
- LTV limits
- Liquidation mechanisms
- Emergency controls
- Automated testing
- Testnet deployment
- Monitoring
- Security reviews
- Independent audits before production deployment

Potential attack vectors include:

- Smart-contract vulnerabilities
- Oracle manipulation
- Reentrancy
- Access-control failures
- Price manipulation
- Flash-loan attacks
- Liquidation exploits
- Accounting errors
- Economic attacks
- Liquidity attacks

No DeFi protocol can guarantee zero risk.

The purpose of the security architecture is to minimize technical and economic risks as much as reasonably possible.

---

## Non-Custodial Design

ICFT is designed to be non-custodial.

Users interact directly with smart contracts through compatible Web3 wallets.

The protocol does not require users to deposit their funds into a centralized exchange.

The smart contracts enforce the rules governing:

- Deposits
- Borrowing
- Repayment
- Withdrawals
- Collateral
- Liquidation

Users remain in control of their wallets and interact with protocol contracts directly.

---

## Technology

ICFT is being designed for EVM-compatible blockchain infrastructure.

The initial technology stack includes:

- Solidity
- EVM-compatible smart contracts
- ERC-20
- Decentralized oracle infrastructure
- Web3 wallets
- Decentralized liquidity
- Automated testing
- Web3 frontend infrastructure

The exact blockchain deployment and infrastructure architecture may evolve during development and testing.

---

## Roadmap

### Phase 1 — Lending MVP

The first stage focuses on validating the core lending mechanism.

Planned functionality:

- ICFT ERC-20 token
- Collateral Vault
- Lending Pool
- ETH collateral
- LTV calculation
- Interest calculation
- Borrowing
- Repayment
- Collateral withdrawal
- Oracle integration
- Risk parameters
- Liquidation mechanism
- Emergency Freeze
- Basic frontend
- Wallet integration
- Testnet deployment
- Automated tests

The main objective is to prove that the fundamental lending architecture works safely.

### Phase 2 — Liquidity and Expansion

The second stage focuses on making ICFT more usable.

Potential functionality:

- ICFT/USDT liquidity
- Additional collateral assets
- ICFT/ETH market
- Improved liquidation
- Automated liquidation keepers
- Liquidity incentives
- Improved Risk Engine
- Portfolio-based collateral
- Improved user interface

### Phase 3 — Programmable Credit

The third stage introduces automated loan management.

Potential functionality:

- Programmable loan parameters
- Automated debt management
- Automated collateral management
- Credit lines
- Self-healing positions
- Advanced risk strategies
- Automated portfolio actions
- Additional DeFi integrations

### Phase 4 — Financial Infrastructure

The fourth stage focuses on expanding ICFT beyond lending.

Potential functionality:

- Integrated DEX
- Advanced liquidity routing
- Developer SDK
- Third-party integrations
- Institutional lending
- Additional financial primitives
- Automated financial agents
- Tokenized real-world assets

---

## Project Status

ICFT is currently an early-stage project under active development.

The immediate objective is to build and test the Lending MVP.

The project is intentionally being developed incrementally.

Lending MVP → Testnet → Security Testing → Liquidity → Mainnet Preparation → Programmable Credit → Financial Infrastructure

Each major stage should be validated before expanding the protocol with additional functionality.

---

## Development Philosophy

ICFT follows a modular development approach.

Core lending functionality should remain separated from:

- Risk management
- Oracle infrastructure
- Liquidity
- Liquidation
- Programmable loan logic
- Exchange infrastructure

This makes the protocol easier to test, audit, maintain, and expand.

Security and risk management take priority over rapid feature expansion.

---

## Contributing

ICFT is an open development project.

Developers, researchers, security specialists, economists, and Web3 contributors are welcome to participate.

Potential contributions include:

- Solidity development
- Smart-contract architecture
- Frontend development
- Testing
- Security research
- Economic modeling
- Risk modeling
- Oracle integrations
- Documentation
- Developer tooling

Contributors can open issues, submit pull requests, or participate in technical discussions.

---

## Security Research

Security researchers are encouraged to review the protocol architecture and identify potential vulnerabilities.

Areas of particular importance include:

- Smart-contract vulnerabilities
- Oracle manipulation
- Reentrancy
- Access-control failures
- Liquidation exploits
- Price manipulation
- Economic attacks
- Liquidity attacks
- Flash-loan attacks
- Accounting errors
- Collateral valuation errors

A formal bug bounty program may be introduced as the protocol approaches production deployment.

---

## Disclaimer

ICFT is an experimental decentralized finance project under development.

The protocol, smart contracts, tokenomics, risk parameters, economic model, supported assets, and planned functionality may change during development and testing.

ICFT does not guarantee profits, token appreciation, liquidity, or protection against market losses.

DeFi protocols involve significant technical, economic, market, smart-contract, oracle, and liquidation risks.

Nothing contained in this repository constitutes financial, investment, legal, or tax advice.

Users should not interact with experimental deployments using funds they cannot afford to lose.

---

## Vision

The long-term vision of ICFT is to create an open and programmable financial infrastructure for crypto assets.

The first step is:

**Crypto Collateral → ICFT Credit → Liquidity**

The long-term objective is:

**Collateral → Credit → Liquidity → Trading → Risk Management → Programmable Loans → Developer Ecosystem**

ICFT aims to move from a crypto lending protocol toward a programmable financial layer where users can use their crypto assets as collateral, access flexible liquidity, automate financial decisions, and interact with an expanding ecosystem of decentralized applications.

The first objective is to make the lending mechanism work.

The next objective is to make it safe.

The long-term objective is to make it composable.

**ICFT — Programmable Credit Infrastructure for Crypto.**