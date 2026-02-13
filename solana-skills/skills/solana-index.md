# Solana Skills Index

This is a master index file that helps Claude Code discover and load the Solana skills.

## Available Skills

### Getting Started
- **File**: `solana-getting-started.md`
- **Topics**: Installation, wallet setup, network configuration, first program

### Core Concepts
- **File**: `solana-core-concepts.md`
- **Topics**: Accounts model, transactions, programs, clusters, compute, PDAs

### Transactions
- **File**: `solana-transactions.md`
- **Topics**: Creating, signing, sending, simulating, confirming transactions

### Accounts
- **File**: `solana-accounts.md`
- **Topics**: Account creation, rent exemption, PDAs, token accounts, closing accounts

### Programs
- **File**: `solana-programs.md`
- **Topics**: Rust/Anchor programs, CPI, state management, testing, deployment

### RPC API
- **File**: `solana-rpc-api.md`
- **Topics**: JSON-RPC methods, subscriptions, error handling, rate limiting

### Tokens
- **File**: `solana-tokens.md`
- **Topics**: SPL tokens, minting, transferring, NFTs, metadata, Token-2022

### Frontend
- **File**: `solana-front-end.md`
- **Topics**: Wallet integration, Web3.js, React, transactions, subscriptions

### Deployment
- **File**: `solana-deployment.md`
- **Topics**: Building, deploying, upgrading, CI/CD, mainnet deployment

### Advanced
- **File**: `solana-advanced.md`
- **Topics**: CPI patterns, security, optimization, DeFi patterns, testing

## Usage in Claude Code

These skills are automatically available when:
- Working in a Solana project directory
- Solana-related keywords are detected
- Explicitly invoked by the user

## Skill Metadata

```yaml
name: solana-skills
version: 1.0.0
description: Comprehensive Solana development skills
language:
  - rust
  - javascript
  - typescript
frameworks:
  - anchor
  - solana-program
  - @solana/web3.js
networks:
  - devnet
  - testnet
  - mainnet-beta
```

## Related Resources

- Solana Documentation: https://solana.com/zh/docs
- Anchor Framework: https://www.anchor-lang.com/
- Solana Cookbook: https://solanacookbook.com/
