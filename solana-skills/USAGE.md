# Solana Skills Plugin - Usage Guide

## Quick Start

### Installation

```bash
# Clone or copy the skills directory
cp -r /path/to/solana-skills/skills ~/.claude/skills/solana-skills
```

### Verification

List the skills to verify installation:

```bash
ls -la ~/.claude/skills/solana-skills/
```

You should see all `.md` skill files.

## Using the Skills

### In Claude Code Desktop

When working on Solana projects, Claude will automatically load relevant skills based on context:

```
I need to deploy my Anchor program to devnet
```

Claude will access `/solana-deployment` skill and provide deployment guidance.

### Explicit Skill Invocation

You can explicitly reference skills:

```
Use the /solana-tokens skill to create a new token mint
```

### Multi-Skill Queries

For complex tasks, Claude combines multiple skills:

```
Create a frontend that allows users to mint NFTs
```

This will combine:
- `/solana-front-end` - Wallet integration
- `/solana-tokens` - NFT creation
- `/solana-transactions` - Transaction handling

## Skill Reference

### Solana Getting Started
**Best for**: New developers, environment setup

Topics covered:
- Solana CLI installation
- Wallet creation and management
- Network configuration (devnet/testnet/mainnet)
- First program compilation

Example queries:
- "How do I install Solana CLI?"
- "Configure Solana for devnet"
- "Request airdrop on devnet"

### Solana Core Concepts
**Best for**: Understanding Solana architecture

Topics covered:
- Accounts model
- Transaction structure
- Program execution
- Clusters and slots
- Compute units
- PDAs

Example queries:
- "Explain Solana's account model"
- "What is a PDA?"
- "How does Proof of History work?"

### Solana Transactions
**Best for**: Creating and sending transactions

Topics covered:
- Building transactions
- Signing transactions
- Transaction simulation
- Error handling
- Priority fees

Example queries:
- "Create a transfer transaction"
- "How to add priority fees?"
- "Why did my transaction fail?"

### Solana Accounts
**Best for**: Account management

Topics covered:
- Creating accounts
- Rent exemption
- PDAs
- Token accounts
- Closing accounts

Example queries:
- "Create a rent-exempt account"
- "Derive a PDA for my program"
- "Close an account and recover lamports"

### Solana Programs
**Best for**: Smart contract development

Topics covered:
- Rust program structure
- Anchor framework
- CPI (Cross-Program Invocation)
- State management
- Testing

Example queries:
- "Create an Anchor program"
- "How to do CPI to another program?"
- "Write unit tests for my program"

### Solana RPC API
**Best for**: Blockchain queries and interaction

Topics covered:
- JSON-RPC methods
- Account queries
- Transaction submission
- WebSocket subscriptions
- Error handling

Example queries:
- "Get account balance via RPC"
- "Subscribe to account changes"
- "Get program accounts"

### Solana Tokens
**Best for**: Token and NFT operations

Topics covered:
- SPL Token program
- Creating mints
- Token accounts
- Token transfers
- NFTs and metadata

Example queries:
- "Create a new token mint"
- "Transfer SPL tokens"
- "Create an NFT with metadata"

### Solana Frontend
**Best for**: Web application development

Topics covered:
- Wallet integration (Phantom, etc.)
- React integration
- Transaction signing
- Real-time updates

Example queries:
- "Integrate Phantom wallet in React"
- "Sign transaction with wallet"
- "Get real-time account updates"

### Solana Deployment
**Best for**: Deploying programs to networks

Topics covered:
- Building programs
- Deployment to devnet/testnet/mainnet
- Upgrading programs
- CI/CD pipelines

Example queries:
- "Deploy my program to devnet"
- "Upgrade program on mainnet"
- "Set up CI/CD for Solana"

### Solana Advanced
**Best for**: Complex patterns and optimization

Topics covered:
- Advanced CPI patterns
- Security best practices
- Performance optimization
- DeFi patterns
- Oracle integration

Example queries:
- "Implement AMM logic"
- "Secure my program against reentrancy"
- "Optimize compute usage"

## Common Workflows

### Creating a New Project

```
Help me create a new Solana project with Anchor
```

Skills involved:
1. `/solana-getting-started` - Verify installation
2. `/solana-programs` - Create project structure
3. `/solana-core-concepts` - Understand the architecture

### Building a DApp

```
I want to build a DApp where users can stake tokens
```

Skills involved:
1. `/solana-programs` - Write staking program
2. `/solana-tokens` - Handle token operations
3. `/solana-front-end` - Build frontend UI
4. `/solana-deployment` - Deploy to devnet

### Debugging Issues

```
My transaction keeps failing with 'ProgramFailedToComplete'
```

Skills involved:
1. `/solana-transactions` - Transaction debugging
2. `/solana-rpc-api` - Get transaction details
3. `/solana-programs` - Program error handling

## Tips for Best Results

### 1. Be Specific
Instead of: "Help with Solana"
Try: "How do I create a PDA in my Anchor program?"

### 2. Provide Context
Include relevant details:
- "Using Anchor framework"
- "On devnet network"
- "With TypeScript frontend"

### 3. Specify Language
- "Show me Rust code for..."
- "JavaScript example for..."
- "Both Rust and TypeScript"

### 4. Reference Previous Work
- "Continuing from the previous transaction example"
- "Build on the PDA pattern we discussed"

## Troubleshooting

### Skills Not Loading

1. Verify installation:
```bash
ls ~/.claude/skills/solana-skills/
```

2. Check file permissions:
```bash
chmod +r ~/.claude/skills/solana-skills/*.md
```

3. Restart Claude Code

### Outdated Information

The skills reference:
- Solana CLI v3.0+
- Anchor framework latest
- Web3.js latest

For version-specific issues, always check:
https://solana.com/docs

## Contributing

To improve these skills:

1. Test code examples
2. Add new patterns
3. Update for latest Solana versions
4. Fix any errors

## Resources

- **Solana Docs**: https://solana.com/zh/docs
- **Anchor**: https://www.anchor-lang.com/
- **Cookbook**: https://solanacookbook.com/
- **Discord**: https://discord.gg/solana

## Support

For specific issues:
1. Check the relevant skill file
2. Visit Solana Stack Exchange
3. Ask in Solana Discord

## Version History

- **v1.0.0** (2026-01-12): Initial release
  - 10 core skills
  - Comprehensive coverage
  - Rust and JavaScript examples
