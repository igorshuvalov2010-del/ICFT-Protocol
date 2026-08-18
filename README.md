ICFT

A programmable crypto-credit protocol that transforms crypto collateral into flexible, automated and programmable liquidity.

Overview

ICFT is a decentralized crypto lending protocol designed to provide users with access to liquidity without requiring them to sell their existing crypto assets.

The core concept is simple: users can deposit supported crypto assets as collateral, borrow ICFT against that collateral, and exchange the borrowed ICFT for USDT or other supported crypto assets through decentralized liquidity markets.

This allows users to access liquidity while maintaining exposure to the assets they already hold.

For example, a user may hold ETH because they believe its long-term value will increase. Selling ETH would provide immediate liquidity, but it would also reduce the user’s exposure to ETH.

With ICFT, the user can instead deposit ETH as collateral, borrow ICFT, exchange ICFT for the liquidity they need, use that liquidity, and later acquire ICFT to repay the debt and unlock their collateral.

The initial focus of ICFT is decentralized crypto lending. Over time, the protocol is designed to evolve toward programmable credit infrastructure, where users can define automated rules for managing their collateralized positions.

The Problem

Crypto holders frequently face a trade-off between maintaining exposure to their assets and obtaining liquidity.

A user may own BTC, ETH, SOL, or other supported crypto assets but still need liquidity for another purpose.

The traditional solution is to sell the asset.

Hold ETH → Need liquidity → Sell ETH → Receive USDT → Lose part of ETH exposure.

Crypto lending provides an alternative:

Hold ETH → Deposit ETH as collateral → Borrow against ETH → Receive liquidity → Maintain ETH exposure.

ICFT is designed around this second model.

The ICFT Approach

ICFT converts supported crypto collateral into access to programmable credit.

The basic process is:

Crypto Collateral → Collateral Vault → Risk Assessment → ICFT Credit → ICFT/USDT or other liquidity → User receives liquidity → Repayment → Collateral Withdrawal.

The protocol does not require users to sell their collateral in order to obtain liquidity.

Instead, collateral remains locked while the user maintains an outstanding debt position.

Core Principles

Non-Custodial

Users interact with smart contracts rather than relying on centralized custody of their assets.

Collateralized Credit

Borrowing capacity is determined by the value and risk characteristics of the user’s collateral.

Automated Risk Management

The protocol continuously evaluates positions using predefined risk parameters and decentralized price data.

Programmable Loans

Users can eventually define predefined rules for how their loan positions should react to changing market conditions.

Automated Liquidation

Unsafe positions can be liquidated automatically according to smart-contract rules.

Open Liquidity

ICFT can interact with decentralized liquidity markets to allow users to exchange borrowed ICFT for other supported assets.

How ICFT Works

1. Deposit Collateral

A user connects a compatible Web3 wallet and deposits a supported crypto asset.

For example:

10 ETH
Market Value: $30,000

The ETH is transferred into the protocol’s collateral vault.

The collateral remains locked while the position is active.

2. Risk Assessment

The protocol determines how much the user can borrow based on the collateral’s value and risk parameters.

For example:

ETH — Maximum LTV: 70%
BTC — Maximum LTV: 70%
SOL — Maximum LTV: 50%

These parameters can change depending on the protocol’s risk model, liquidity conditions, volatility, and other factors.

Loan-to-Value (LTV)

LTV is one of the most important risk metrics in the ICFT protocol.

LTV represents the relationship between outstanding debt and collateral value.

LTV = Debt / Collateral Value × 100%

For example:

Collateral: $100,000
Debt: $50,000
LTV: 50%

If the collateral falls in value while the debt remains unchanged, the LTV increases.

For example:

Collateral: $80,000
Debt: $50,000
LTV: 62.5%

This means that market movements can directly affect the safety of a borrowing position.

3. Borrow ICFT

Once the user’s collateral and borrowing capacity have been determined, the user can borrow ICFT.

For example:

Collateral Value: $100,000
Maximum LTV: 60%
Maximum Borrowing Capacity: $60,000

The user could borrow less than the maximum.

For example:

Borrowed: $40,000 ICFT
Initial LTV: 40%

The borrowed ICFT is transferred to the user’s wallet.

4. Use ICFT

Once ICFT has been received, the user is free to use the tokens.

For example:

ICFT → ICFT/USDT → USDT → BTC/ETH/other assets

The user may also transfer ICFT to another wallet or interact with other compatible applications.

ICFT therefore acts as the native credit asset of the initial protocol architecture.

5. Repay the Loan

To close the position, the user acquires the required amount of ICFT and repays the outstanding debt.

After the debt and applicable fees have been repaid, the collateral becomes available for withdrawal.

User acquires ICFT → Repay debt → Debt = 0 → Withdraw collateral.

Collateral Architecture

The protocol is designed to support multiple forms of crypto collateral over time.

Potential collateral assets may include ETH, BTC representations compatible with the selected EVM environment, SOL representations compatible with the selected EVM environment, stablecoins, other liquid crypto assets, and potentially tokenized real-world assets in future versions.

Each collateral asset must have its own risk parameters.

The protocol should not treat every asset identically.

A highly liquid and established asset can have significantly different risk parameters from a volatile or illiquid asset.

Collateral Vault

Collateral is stored inside smart-contract-controlled vaults.

The vault architecture is responsible for accepting collateral deposits, tracking user balances, preventing unauthorized withdrawals, linking collateral to debt positions, enforcing withdrawal restrictions while debt exists, and interacting with the liquidation mechanism.

Lending Pool

The Lending Pool is the core liquidity layer of the protocol.

It manages the available liquidity required for borrowing and repayment.

The Lending Pool can interact with borrower positions, protocol reserves, liquidity providers, interest accounting, risk parameters, and liquidation mechanisms.

The exact pool architecture and capital utilization model may evolve during development and testing.

Interest and Debt

Borrowing may accrue interest according to the protocol’s interest-rate model.

A user’s debt can therefore be represented as:

Principal + Accrued Interest = Outstanding Debt

The interest model can be designed to respond to utilization and liquidity conditions.

For example, higher utilization can result in higher borrowing rates in order to encourage repayment and attract additional liquidity.

The final interest-rate model will be determined during protocol development and testing.

Health Factor

In addition to LTV, ICFT can use a health metric to determine the safety of a borrowing position.

A simplified representation is:

Health Factor > 1 — Safe

Health Factor ≈ 1 — Critical

Health Factor < 1 — Liquidatable

The exact calculation can depend on collateral value, collateral risk parameters, outstanding debt, liquidation threshold, and asset-specific factors.

The purpose of the health metric is to provide a standardized way for the protocol to determine when a position has become unsafe.

Automated Liquidation

If a user’s position becomes undercollateralized, ICFT can automatically initiate liquidation.

For example:

ETH Collateral: $100,000
Debt: $50,000
LTV: 50%

If ETH falls significantly:

ETH Collateral: $62,500
Debt: $50,000
LTV: 80%

If the liquidation threshold is reached, the protocol can begin liquidating the position.

The liquidation mechanism can detect the unsafe position, determine the amount of collateral that needs to be sold, execute the liquidation, exchange collateral for the required debt asset, repay outstanding debt, and return remaining collateral to the user where applicable.

The objective is not necessarily to sell the entire position.

A partial liquidation mechanism can be used to restore a position to a safer risk level while minimizing unnecessary collateral sales.

Liquidation Keepers

Smart contracts cannot independently create blockchain transactions.

Therefore, automated liquidation can use external keepers or automated transaction executors.

The keeper does not decide whether the position should be liquidated.

Instead, it calls the liquidation function, and the smart contract checks whether the liquidation conditions have actually been met.

This prevents an external keeper from arbitrarily liquidating a healthy position.

Liquidation Incentives

Liquidators may receive a predefined liquidation incentive.

The incentive exists to make it economically attractive for participants to execute liquidations when positions become unsafe.

The exact liquidation bonus and mechanism will depend on the protocol’s risk model.

Oracle System

Accurate collateral valuation is critical to the protocol.

ICFT therefore requires reliable price data for supported collateral and debt assets.

The oracle system can provide asset prices, price updates, deviation checks, stale-price protection, and fallback mechanisms where appropriate.

The Risk Engine uses oracle data to calculate collateral value, LTV, health factor, borrowing capacity, and liquidation eligibility.

A manipulation-resistant oracle architecture is a fundamental security requirement for the protocol.

Risk Engine

The Risk Engine is responsible for determining the financial safety of protocol positions.

It can evaluate collateral value, debt value, LTV, health factor, asset volatility, collateral parameters, and liquidity conditions.

The Risk Engine should operate according to predefined rules rather than discretionary manual decisions.

For example:

ETH Maximum LTV: 70%
Liquidation Threshold: 80%
User LTV: 54%
Position Status: SAFE

If market conditions change:

User LTV: 79%
Position Status: HIGH RISK

If the liquidation threshold is reached:

User LTV: 80%
Position Status: LIQUIDATABLE

Programmable Loans

One of the long-term innovations planned for ICFT is programmable loan management.

Traditional lending generally follows:

Borrow → Monitor manually → Repay manually.

ICFT can evolve toward:

Borrow → Define risk rules → Smart Contract monitors position → Automatic actions.

Users could configure predefined actions such as automatic partial repayment, additional collateral deposits, partial liquidation, automated position reduction, and automated debt management.

For example:

Collateral: ETH
Loan: 50,000 ICFT

If LTV > 60%: attempt partial debt repayment.

If LTV > 70%: increase risk response.

If liquidation threshold is reached: initiate liquidation.

Users would configure these options through the ICFT interface rather than directly writing smart-contract code.

Protocol Risk Limits

Programmability does not mean unlimited user control.

The protocol defines global safety boundaries.

For example, if the protocol’s maximum LTV is 70%, a user cannot configure a maximum LTV of 95%.

This creates two layers:

Protocol Risk Limits → User-Defined Parameters → Smart Contract Execution

The user’s strategy can operate only inside the boundaries established by the protocol.

Self-Healing Positions

A future version of ICFT can introduce self-healing loan positions.

Instead of waiting until liquidation becomes unavoidable, the protocol can automatically react to deteriorating positions.

For example:

LTV = 55% → Normal

LTV = 60% → Warning

LTV = 65% → Automatic risk action

LTV = 70% → Partial liquidation if required

The goal is to move away from a binary model where a position is either healthy or liquidated.

Instead, the protocol can continuously manage risk and attempt to preserve healthy positions.

Liquidity

Liquidity is essential for ICFT because borrowers must be able to exchange ICFT for other assets.

The protocol can support markets such as:

ICFT/USDT
ICFT/ETH
ICFT/BTC

Additional markets may be introduced as liquidity and demand develop.

Liquidity Providers

External liquidity providers can contribute assets to supported liquidity markets.

For example, liquidity providers can supply USDT to an ICFT/USDT pool.

Protocol-controlled ICFT reserves can initially be paired with external USDT liquidity to bootstrap the market.

Liquidity providers can receive trading fees and, where applicable, ICFT-based liquidity incentives.

The exact incentive structure will depend on the protocol’s economics and liquidity requirements.

Liquidity Bootstrapping

Early-stage protocols face a liquidity problem: users need liquidity to trade ICFT, but liquidity providers need users and trading volume to justify providing liquidity.

ICFT can address this initially through protocol-controlled reserves.

Protocol ICFT reserves can be paired with external USDT liquidity to create initial ICFT/USDT markets.

Over time, the objective is to increase organic liquidity and reduce reliance on protocol-controlled liquidity.

ICFT Token

ICFT is the native asset of the protocol.

Initial total supply:

1,000,000,000 ICFT

Initial reference price:

$0.50

The token is intended to serve as the native credit and ecosystem asset of the ICFT protocol.

Potential utility includes borrowing, lending, liquidity incentives, trading, governance, protocol participation, potential staking or security mechanisms, and future ecosystem functionality.

The exact utility, distribution, vesting schedules, and allocation structure are defined separately in the project’s tokenomics.

ICFT Economic Model

The protocol’s economic model is designed around several interacting components:

Collateral → Borrowing → ICFT Demand → Liquidity → Trading → Fees → Protocol Economics.

Users require ICFT when they use the lending system.

Liquidity providers support the ability to exchange ICFT.

Traders create volume and generate fees.

The protocol can allocate fees according to its governance and treasury structure.

The objective is to create an economic cycle in which protocol usage generates sustainable activity rather than relying solely on token speculation.

Protocol-Owned Liquidity

During the early stages, ICFT reserves may be used to bootstrap liquidity.

This allows the protocol to create initial markets before sufficient external liquidity exists.

Protocol-owned liquidity should be managed transparently and according to predefined rules.

Emergency Freeze

ICFT can include emergency controls designed to protect users and protocol funds during critical events.

Potential emergency scenarios include oracle failure, smart-contract vulnerability, abnormal price movement, liquidity manipulation, unexpected protocol behavior, and critical security incidents.

An emergency pause can temporarily restrict selected protocol functions while the development or governance process investigates and responds.

Emergency controls should be subject to strict permissions and transparent governance.

Security Architecture

Security is a fundamental requirement of ICFT.

The protocol is designed around audited smart contracts, modular contract architecture, access control, oracle protections, LTV limits, liquidation mechanisms, emergency pause functionality, automated testing, testnet deployment, monitoring, bug reporting, and independent security audits before production deployment.

No smart-contract system can guarantee zero risk.

The purpose of the security architecture is to reduce technical, economic, oracle, and liquidation risks as much as reasonably possible.

Non-Custodial Architecture

ICFT is designed as a non-custodial protocol.

Users interact directly with smart contracts using compatible Web3 wallets.

The protocol does not require users to deposit funds into a centralized exchange or give a centralized entity direct custody of their assets.

The smart contracts enforce the rules governing deposits, borrowing, repayments, withdrawals, collateral, and liquidation.

Future Decentralized Exchange

A future version of ICFT may introduce an integrated decentralized exchange.

The purpose would be to allow users to move directly from collateral to credit to other assets without requiring the user to leave the ICFT interface.

For example:

Collateral → ICFT Loan → ICFT → BTC / ETH / USDT / Other Assets.

The integrated exchange could eventually provide ICFT/USDT, ICFT/ETH, ICFT/BTC, additional crypto markets, liquidity aggregation, optimized routing, and reduced trading friction.

The DEX is considered a later-stage expansion rather than part of the initial Lending MVP.

Future Financial Infrastructure

The long-term vision of ICFT extends beyond lending.

The protocol can evolve toward a broader crypto financial infrastructure consisting of collateral, credit, liquidity, trading, risk management, payments, and programmable financial strategies.

Potential future components include universal collateral accounts, programmable credit lines, automated financial strategies, integrated trading, developer SDKs, third-party DeFi integrations, institutional credit infrastructure, tokenized real-world assets, automated risk management, and financial agents.

The objective is not simply to create another lending application, but to build infrastructure that can support additional financial applications over time.

Developer Ecosystem

A long-term goal of ICFT is to allow third-party developers to build applications on top of the protocol.

Potential developer interfaces could include functions for depositing collateral, withdrawing collateral, borrowing, repaying, obtaining credit limits, checking health factors, retrieving collateral values, retrieving debt positions, and executing liquidations.

Developers could eventually use ICFT infrastructure to build crypto credit applications, payment applications, trading interfaces, portfolio management tools, automated financial strategies, institutional products, and other DeFi applications.

This would allow ICFT to evolve from a single application into a broader financial infrastructure layer.

Roadmap

Phase 1 — Lending MVP

The first development phase focuses on proving the core lending mechanism.

Planned functionality includes:

* ICFT ERC-20 token
* Collateral vault
* Lending pool
* ETH collateral
* LTV calculation
* Interest calculation
* Borrowing
* Repayment
* Collateral withdrawal
* Oracle integration
* Risk parameters
* Liquidation mechanism
* Emergency pause
* Basic frontend
* Web3 wallet integration
* Testnet deployment
* Automated tests

The objective of Phase 1 is to validate the fundamental lending architecture and risk model.

Phase 2 — Liquidity and Expansion

The second phase focuses on increasing the usability of ICFT.

Potential features include:

* ICFT/USDT liquidity
* Additional collateral assets
* ICFT/ETH market
* Improved liquidation mechanisms
* Automated liquidation keepers
* Liquidity incentives
* Improved risk engine
* Portfolio-based collateral
* Improved user interface

Phase 3 — Programmable Credit

The third phase introduces more advanced credit functionality.

Potential features include:

* Programmable loan parameters
* Automated debt management
* Automated collateral management
* Credit lines
* Self-healing positions
* Advanced risk strategies
* Automated portfolio actions
* Additional DeFi integrations

Phase 4 — ICFT Financial Infrastructure

The fourth phase focuses on expanding the protocol beyond the original lending application.

Potential functionality includes:

* Integrated decentralized exchange
* Advanced liquidity routing
* Developer SDK
* Third-party protocol integrations
* Institutional lending
* Additional financial primitives
* Automated financial agents
* Tokenized real-world assets

Technology

ICFT is being designed for EVM-compatible blockchain infrastructure.

The initial technical stack includes:

* Solidity
* EVM-compatible smart contracts
* ERC-20
* Decentralized oracle infrastructure
* Web3 wallets
* Decentralized liquidity
* Automated testing
* Frontend Web3 integration

The final blockchain deployment and infrastructure architecture may evolve during development and testing.

Project Status

ICFT is currently an early-stage project under active development.

The immediate objective is to build and test the Lending MVP.

The initial priority is not to launch every planned feature simultaneously.

Instead, development will proceed incrementally:

Lending MVP → Testnet → Security Testing → Liquidity → Mainnet Preparation → Programmable Credit → Expanded Financial Infrastructure.

Each stage is intended to be validated before moving to the next stage.

Development Philosophy

ICFT follows a modular development approach.

Core lending functionality should remain separated from risk management, oracle infrastructure, liquidity, liquidation, programmable loan logic, and future exchange infrastructure.

This allows individual components to be upgraded, tested, and audited without requiring the entire protocol to be redesigned.

Security and risk management take priority over rapid feature expansion.

Contributing

ICFT is an open development project.

Developers, researchers, security specialists, economists, and Web3 contributors are welcome to participate.

Potential contributions include Solidity development, smart-contract architecture, frontend development, testing, security research, economic modeling, risk modeling, oracle integrations, documentation, and developer tooling.

Contributors can open issues, submit pull requests, or participate in technical discussions.

Security Research

Security researchers are encouraged to review the protocol architecture and identify potential vulnerabilities.

Areas of particular importance include smart-contract vulnerabilities, oracle manipulation, reentrancy, access-control failures, liquidation exploits, price manipulation, economic attacks, liquidity attacks, flash-loan attacks, accounting errors, and collateral valuation errors.

A formal bug bounty program may be introduced as the protocol approaches production deployment.


Vision

The long-term vision of ICFT is to create an open and programmable financial infrastructure for crypto assets.

The first step is simple:

Crypto Collateral → ICFT Credit → Liquidity

The long-term objective is much broader:

Collateral → Credit → Liquidity → Trading → Risk Management → Programmable Loans → Developer Ecosystem

ICFT aims to move from a simple crypto lending protocol toward a programmable financial layer where users can use their crypto assets as collateral, access flexible liquidity, automate financial decisions, and interact with an expanding ecosystem of decentralized applications.

The first objective is to make the lending mechanism work.

The next objective is to make it safe.

The long-term objective is to make it composable.

ICFT — Programmable Credit Infrastructure for Crypto
