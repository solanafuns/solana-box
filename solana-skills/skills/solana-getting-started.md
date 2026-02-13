# Solana Getting Started

Welcome to Solana development! This skill provides guidance on setting up your development environment and taking your first steps on the Solana blockchain.

## Installation

### Installing Solana CLI

The Solana CLI is your primary tool for interacting with the Solana network.

**Install on Linux/macOS:**
```bash
sh -c "$(curl -sSfL https://release.solana.com/stable/install)"
```

**Install on Windows:**
```bash
cmd /c curl https://release.solana.com/stable/install/init.bat -o init.bat
init.bat
```

**Verify installation:**
```bash
solana --version
```

### Installing Rust Toolchain

Solana programs are written in Rust. Install the Rust toolchain:

```bash
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
source $HOME/.cargo/env
```

### Installing Anchor Framework (Optional but Recommended)

Anchor simplifies Solana program development:

```bash
cargo install --git https://github.com/coral-xyz/anchor avm --locked --force
avm install latest
avm use latest
```

## Configuration

### Setting Up Your Wallet

**Create a new keypair:**
```bash
solana-keygen new
```

**Check your wallet address:**
```bash
solana address
```

**Check your balance:**
```bash
solana balance
```

### Configuring the Network

**Switch to devnet (for testing):**
```bash
solana config set --url devnet
```

**Switch to testnet:**
```bash
solana config set --url testnet
```

**Switch to mainnet-beta:**
```bash
solana config set --url mainnet-beta
```

**View current configuration:**
```bash
solana config get
```

### Getting SOL on Devnet

**Request an airdrop (devnet/testnet only):**
```bash
solana airdrop 2
```

## First Steps

### Creating Your First Project

**Using Anchor:**
```bash
anchor init my-project
cd my-project
```

**Using plain Rust:**
```bash
cargo new my-program --lib
cd my-program
```

Add to `Cargo.toml`:
```toml
[dependencies]
solana-program = "1.18"
```

### Building a Program

**With Anchor:**
```bash
anchor build
```

**With Cargo:**
```bash
cargo build-bpf
```

### Deploying to Devnet

**With Anchor:**
```bash
anchor deploy
```

**With Solana CLI:**
```bash
solana program deploy ./target/deploy/my_program.so
```

## Basic Operations

### Transferring SOL

```bash
solana transfer <RECIPIENT_ADDRESS> 0.1
```

### Checking Account Information

```bash
solana account <ACCOUNT_ADDRESS>
```

### Getting Recent Blockhash

```bash
solana blockhash
```

## Environment Variables

**Set custom RPC URL:**
```bash
export SOLANA_RPC_URL=https://api.devnet.solana.com
```

**Set custom keypair path:**
```bash
export SOLANA_KEYPAIR_PATH=/path/to/keypair.json
```

**Use with proxy (if needed in China):**
```bash
export https_proxy=http://host.docker.internal:7890
export http_proxy=http://host.docker.internal:7890
export all_proxy=socks5://host.docker.internal:7890
```

## Verification Checklist

- [ ] Solana CLI installed and version displayed
- [ ] Rust toolchain installed
- [ ] Wallet keypair created
- [ ] Network configured (devnet for testing)
- [ ] Received airdrop SOL (devnet/testnet)
- [ ] Successfully built a sample program
- [ ] Successfully deployed to devnet

## Common Issues

**Issue:** `Error: Account not found`
- Ensure you've requested an airdrop and have SOL in your wallet

**Issue:** `Error: Invalid keypair`
- Check that your keypair file path is correct

**Issue:** `Error: Connection refused`
- Verify your network configuration and RPC endpoint
- Check if you need to use a proxy

## Next Steps

After completing setup, explore:
- `/solana-core-concepts` - Understanding Solana's architecture
- `/solana-transactions` - Creating and sending transactions
- `/solana-programs` - Writing smart contracts

## Resources

- Official Solana Docs: https://solana.com/zh/docs
- Solana Cookbook: https://solanacookbook.com/
- Discord: https://discord.gg/solana
