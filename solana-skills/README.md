# Solana Skills Plugin for Claude Code

A comprehensive collection of Solana development skills for Claude Code, providing quick reference and guidance for Solana blockchain development.

## Overview

This plugin contains modular skills covering all major aspects of Solana development, from getting started to advanced DeFi patterns.

## Installation

### Method 1: Copy Skills Directory

```bash
# Copy the skills to your Claude skills directory
cp -r solana-skills/skills ~/.claude/skills/

# Or on Windows
xcopy /E /I solana-skills\skills %APPDATA%\Claude\skills
```

### Method 2: Symbolic Link (Recommended)

```bash
# Create symbolic link to easily update
ln -s /path/to/solana-skills/skills ~/.claude/skills/solana-skills
```

### Method 3: Add to Claude Configuration

Add to your Claude settings:

```json
{
  "skills": [
    "/path/to/solana-skills/skills"
  ]
}
```

## Available Skills

| Skill | Description |
|-------|-------------|
| **solana-getting-started** | Installation, setup, and first steps on Solana |
| **solana-core-concepts** | Understanding Solana architecture and model |
| **solana-transactions** | Creating, signing, and sending transactions |
| **solana-accounts** | Managing accounts and account data |
| **solana-programs** | Writing smart contracts in Rust/Anchor |
| **solana-rpc-api** | Using the JSON-RPC API |
| **solana-tokens** | SPL Token operations and NFTs |
| **solana-front-end** | Wallet integration and frontend development |
| **solana-deployment** | Deploying programs to networks |
| **solana-advanced** | Advanced patterns and optimization |

## Usage

### Using Skills in Claude Code

When working on a Solana project, you can invoke these skills directly:

```
I need help with deploying my Solana program to devnet.
```

Claude will automatically load the `/solana-deployment` skill and provide relevant guidance.

### Skill Categories

**Beginner Path:**
1. `solana-getting-started` - Set up your environment
2. `solana-core-concepts` - Learn the fundamentals
3. `solana-transactions` - Create your first transaction

**Program Development:**
1. `solana-accounts` - Understand account management
2. `solana-programs` - Write smart contracts
3. `solana-deployment` - Deploy your programs
4. `solana-advanced` - Master advanced patterns

**Frontend Development:**
1. `solana-transactions` - Build transactions
2. `solana-rpc-api` - Query the blockchain
3. `solana-tokens` - Handle tokens and NFTs
4. `solana-front-end` - Integrate wallets

## Skill Contents

Each skill includes:
- **Code Examples** - Rust and JavaScript examples
- **CLI Commands** - Shell commands for common tasks
- **Best Practices** - Security and optimization tips
- **Common Issues** - Troubleshooting guidance
- **Resources** - Links to official documentation

## Example Workflows

### Creating a New Token

```
I want to create a new SPL token with 9 decimals on devnet.
```

Claude will guide you through:
1. Using `/solana-getting-started` to verify setup
2. Using `/solana-tokens` to create the mint
3. Using `/solana-transactions` to mint initial supply

### Deploying a Program

```
Help me deploy my Anchor program to mainnet.
```

Claude will guide you through:
1. Using `/solana-deployment` for deployment steps
2. Using `/solana-programs` to verify program structure
3. Using `/solana-advanced` for security considerations

## Configuration

### Network Configuration

The skills reference these default networks:
- **Devnet**: `https://api.devnet.solana.com`
- **Testnet**: `https://api.testnet.solana.com`
- **Mainnet**: `https://api.mainnet-beta.solana.com`

### Custom RPC Endpoints

You can use custom RPC providers in the examples:
- QuickNode
- Alchemy
- Helius
- Triton

## Contributing

### Adding New Skills

To add a new skill:

1. Create a new markdown file in `skills/`
2. Follow the naming convention: `solana-topic-name.md`
3. Include these sections:
   - Overview
   - Code examples (Rust and JavaScript)
   - CLI commands
   - Best practices
   - Common issues
   - Resources

### Updating Skills

To update an existing skill:
1. Edit the corresponding markdown file
2. Ensure code examples are tested
3. Update documentation links
4. Add new patterns and best practices

## Resources

- **Official Solana Docs**: https://solana.com/zh/docs
- **Solana Cookbook**: https://solanacookbook.com/
- **Anchor Docs**: https://www.anchor-lang.com/docs
- **Solana Stack Exchange**: https://solana.stackexchange.com/

## License

This skills plugin is provided as-is for educational purposes.

## Support

For issues or questions:
- Check the specific skill for troubleshooting
- Visit Solana Stack Exchange
- Join the Solana Discord

## Changelog

### v1.0.0 (2026-01-12)
- Initial release with 10 core skills
- Coverage of all major Solana development topics
- Rust and JavaScript examples throughout
- CLI commands for all operations
