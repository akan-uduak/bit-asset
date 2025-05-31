# BitAsset Protocol

## Fractional Real-World Asset Tokenization on Bitcoin via Stacks

---

## Overview

**BitAsset Protocol** is a decentralized Layer 2 solution for tokenizing and governing real-world assets (RWAs) on the Bitcoin network via the [Stacks blockchain](https://www.stacks.co). It enables the creation of **Semi-Fungible Tokens (SFTs)** backed by physical or digital assets, allowing fractional ownership, trustless dividend distribution, and community-driven governance — all secured by Bitcoin.

---

## 🌉 Bridging Bitcoin with Real-World Finance

The protocol aims to bridge the gap between traditional financial assets and the Bitcoin DeFi ecosystem by providing:

* Full **on-chain asset registry and ownership tracking**
* Tokenized fractional investment (1 asset = 100,000 tokens)
* **Decentralized governance mechanisms** for asset proposals and decisions
* **Automated dividend distribution** to token holders
* Compliance and **KYC enforcement** integrated into the smart contract layer

---

## 📐 System Architecture

```text
                            ┌───────────────────────────┐
                            │     Bitcoin Layer 1       │
                            │   (Security and Finality) │
                            └────────────┬──────────────┘
                                         │
                                         ▼
                          ┌─────────────────────────────┐
                          │       Stacks Layer 2        │
                          │  (Smart Contracts in Clarity│
                          └────────────┬────────────────┘
                                       │
            ┌─────────────────────────────────────────────────────┐
            │                     BitAsset Protocol               │
            │─────────────────────────────────────────────────────│
            │ ▸ Asset Registry (tokenized RWAs)                   │
            │ ▸ Token Ownership Ledger (SFT-based)                │
            │ ▸ KYC Verification Layer                            │
            │ ▸ Price Oracle Feeds                                │
            │ ▸ Dividend Distribution Engine                      │
            │ ▸ Governance Proposal & Voting System               │
            └─────────────────────────────────────────────────────┘
                                       │
                                       ▼
                         ┌──────────────────────────┐
                         │    Frontend / DApp UI    │
                         │  (Wallets, Dashboards)   │
                         └──────────────────────────┘
```

---

## ✨ Features

| Feature                      | Description                                                       |
| ---------------------------- | ----------------------------------------------------------------- |
| 🧩 Fractional Ownership      | Tokenize any asset into 100,000 SFTs for divisible investment.    |
| 🛡 KYC & Compliance          | Integrated compliance with configurable levels and expiry.        |
| 📊 Oracle Price Feeds        | Real-time value updates for assets through oracle integration.    |
| 🗳 On-Chain Governance       | Token-weighted voting for proposal creation, asset updates, etc.  |
| 💰 Automated Dividends       | Distribution based on token ownership and dividend pool.          |
| 📈 Asset Valuation Tracking  | Asset values update over time with price feed input.              |
| 🧾 Proposal-Based Management | Modify or operate on assets through community-approved proposals. |

---

## 🧱 Data Model Highlights

### 1. Asset Registry

Stores metadata, valuation, owner info, and lock state.

```clarity
(map assets { asset-id: uint } { owner, metadata-uri, asset-value, ... })
```

### 2. Token Balances

Manages semi-fungible token balances per asset per address.

```clarity
(map token-balances { owner, asset-id } { balance: uint })
```

### 3. Governance Proposals

Create proposals for asset decisions with voting thresholds.

```clarity
(map proposals { proposal-id } { title, asset-id, votes-for, ... })
```

### 4. Dividend Claims

Track last claimed dividend amounts per holder per asset.

```clarity
(map dividend-claims { asset-id, claimer } { last-claimed-amount })
```

---

## ⚙️ Smart Contract Functions

### ✅ Public Functions

* `register-asset(uri, value)` — Register a new tokenized asset.
* `create-proposal(asset-id, title, duration, min-votes)` — Launch a proposal.
* `vote(proposal-id, vote-for, amount)` — Vote on active proposals.
* `claim-dividends(asset-id)` — Claim share of dividend pool.

### 🔍 Read-Only Queries

* `get-asset-info(asset-id)`
* `get-balance(owner, asset-id)`
* `get-proposal(proposal-id)`
* `get-price-feed(asset-id)`
* `get-last-claim(asset-id, claimer)`
* `get-current-asset-count`
* `get-current-proposal-count`

---

## 🛡 Security and Compliance

* **Admin role** controlled by `contract-owner`
* KYC enforcement required for critical interactions
* Boundaries enforced via robust input validation
* Maximum values set to prevent overflows and misuse

---

## 🧪 Example Workflow

1. **Admin registers asset**:
   `register-asset("ipfs://metadata", u1000000)`

2. **Investor buys tokens**:
   (Handled off-chain via exchange or transfer)

3. **Asset generates income**:
   Admin updates `total-dividends`

4. **Holders claim dividends**:
   `claim-dividends(asset-id)`

5. **Holders initiate a vote**:
   `create-proposal(asset-id, "Change oracle", duration, min-votes)`

6. **Others vote with SFTs**:
   `vote(proposal-id, true, amount)`

---

## 🧠 Future Enhancements

* Integration with NFT-based proof of ownership
* DAO treasury integration
* Marketplace and swap DApp
* zkKYC integration for privacy-preserving compliance
* Modular oracle plugin support

---

## 📜 License

MIT License © BitAsset Protocol Contributors

---

## 🧩 Contributing

We welcome developers, legal engineers, and Bitcoin ecosystem contributors to collaborate. Please fork, improve, and submit pull requests or open issues.
