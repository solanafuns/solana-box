# Solana Deployment

This skill covers deploying Solana programs to different networks and managing program upgrades.

## Network Overview

### Solana Networks

| Network | Purpose | SOL Value | Faucet |
|---------|---------|-----------|--------|
| **Localhost** | Local development | None | N/A |
| **Devnet** | Development testing | Test SOL | https://faucet.solana.com/ |
| **Testnet** | Pre-production testing | Test SOL | https://faucet.solana.com/ |
| **Mainnet-Beta** | Production | Real SOL | None |

### Switching Networks

```bash
# Devnet
solana config set --url devnet

# Testnet
solana config set --url testnet

# Mainnet
solana config set --url mainnet-beta

# Localnet
solana config set --url localhost
```

## Building Programs

### Using Anchor

```bash
# Build program
anchor build

# Build specific program
anchor build --program-name my_program

# Build with verifiable output
anchor build --verifiable

# Build without anchor
cargo build-bpf
```

### Build Output

After building, the program is located at:
```
target/deploy/YOUR_PROGRAM.so
```

### Program Size

Check program size:
```bash
ls -lh target/deploy/YOUR_PROGRAM.so
```

Max program size: **256 KB** (upgradable) or **128 KB** (immutable)

## Deployment

### Deploy with Anchor

```bash
# Deploy to configured network
anchor deploy

# Deploy specific program
anchor deploy --program-name my_program

# Deploy with specific provider
anchor deploy --provider.cluster devnet
```

### Deploy with Solana CLI

```bash
# Basic deployment
solana program deploy target/deploy/my_program.so

# Deploy with specific keypair
solana program deploy target/deploy/my_program.so --keypair /path/to/deploy-keypair.json

# Deploy with upgrade authority
solana program deploy target/deploy/my_program.so --upgrade-authority AUTHORITY_ADDRESS
```

### Deployment Example

```bash
# 1. Set network to devnet
solana config set --url devnet

# 2. Ensure you have SOL
solana balance

# 3. Request airdrop if needed (devnet/testnet only)
solana airdrop 2

# 4. Deploy program
solana program deploy target/deploy/my_program.so

# Output:
# Program Id: YOUR_PROGRAM_ID_HERE
```

## Upgrade Authority

### Set Upgrade Authority

```bash
# Set upgrade authority after deployment
solana program set-upgrade-authority PROGRAM_ID UPGRADE_AUTHORITY

# Disable upgrades (make immutable)
solana program set-upgrade-authority PROGRAM_ID --final
```

### Show Upgrade Authority

```bash
solana program show PROGRAM_ID
```

### Transfer Upgrade Authority

```bash
solana program set-upgrade-authority PROGRAM_ID NEW_AUTHORITY
```

## Upgrading Programs

### Upgrade with Anchor

```bash
# Build new version
anchor build

# Upgrade program
anchor upgrade target/deploy/my_program.so --program-id PROGRAM_ID

# Upgrade with specific authority
anchor upgrade target/deploy/my_program.so --program-id PROGRAM_ID --authority AUTHORITY_KEYPAIR
```

### Upgrade with CLI

```bash
# Basic upgrade
solana program upgrade PROGRAM_ID target/deploy/my_program.so

# With specific authority
solana program upgrade PROGRAM_ID target/deploy/my_program.so --upgrade-authority-keypair /path/to/keypair.json

# With final flag (make immutable after upgrade)
solana program upgrade PROGRAM_ID target/deploy/my_program.so --final
```

## Closing Programs

### Close Program on Mainnet

```bash
# Close program and recover lamports
solana program close PROGRAM_ID RECIPIENT_ADDRESS
```

**Note:** Only programs with upgrade authority can be closed.

## Localnet Deployment

### Start Local Validator

```bash
# Start local validator
solana-test-validator

# With specific ledger directory
solana-test-validator --ledger /path/to/ledger

# With specific port
solana-test-validator --rpc-port 8900

# With logging
solana-test-validator --log -r

# With genesis programs
solana-test-validator --bpf-program PROGRAM_ID /path/to/program.so
```

### Deploy to Localnet

```bash
# In another terminal
solana config set --url localhost

# Deploy program
anchor deploy

# Or with solana CLI
solana program deploy target/deploy/my_program.so
```

## CI/CD Deployment

### GitHub Actions Example

```yaml
name: Deploy to Devnet

on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest

    steps:
      - uses: actions/checkout@v3

      - name: Install Solana CLI
        run: |
          sh -c "$(curl -sSfL https://release.solana.com/stable/install)"
          echo "$HOME/.local/share/solana/install/active_release/bin" >> $GITHUB_PATH

      - name: Install Anchor
        run: |
          cargo install --git https://github.com/coral-xyz/anchor avm --locked --force
          avm install latest
          avm use latest

      - name: Configure Solana
        run: solana config set --url devnet

      - name: Deploy to Devnet
        env:
          ANCHOR_WALLET: ${{ secrets.ANCHOR_WALLET }}
        run: anchor deploy --provider.cluster devnet
```

### Docker Deployment

```dockerfile
FROM rust:1.70 as builder

WORKDIR /app
COPY . .

# Install Solana
RUN sh -c "$(curl -sSfL https://release.solana.com/stable/install)"

# Install Anchor
RUN cargo install --git https://github.com/coral-xyz/anchor avm --locked --force
RUN avm install latest && avm use latest

# Build program
RUN anchor build

# Deploy stage
FROM ubuntu:22.04

RUN apt-get update && apt-get install -y curl

# Install Solana CLI
RUN sh -c "$(curl -sSfL https://release.solana.com/stable/install)"

WORKDIR /app
COPY --from=builder /app/target/deploy ./target/deploy

# Deploy script
COPY deploy.sh .
RUN chmod +x deploy.sh

CMD ["./deploy.sh"]
```

## Deployment Checklist

### Pre-Deployment

- [ ] Code reviewed and audited
- [ ] Tests passing
- [ ] Program size under 256 KB
- [ ] Upgrade authority configured
- [ ] Documentation updated

### Devnet Deployment

- [ ] Switch to devnet
- [ ] Request airdrop if needed
- [ ] Deploy program
- [ ] Test all instructions
- [ ] Verify program ID

### Mainnet Deployment

- [ ] Backup deployment keypair
- [ ] Use hardware wallet for upgrade authority
- [ ] Set appropriate upgrade authority
- [ ] Deploy program
- [ ] Verify on Solscan
- [ ] Test with small amounts first

## Monitoring Deployed Programs

### Get Program Account

```bash
solana account PROGRAM_ID
```

### Get Program Size

```bash
solana program show PROGRAM_ID
```

### Monitor Logs

```bash
# Show recent program logs
solana logs PROGRAM_ID

# Stream logs
solana logs PROGRAM_ID --url localhost
```

## Deployment Best Practices

1. **Test thoroughly on devnet** - Catch bugs before mainnet
2. **Use upgrade authority wisely** - Control who can upgrade
3. **Backup deployment keys** - Never lose upgrade authority
4. **Document program ID** - Keep track of deployed programs
5. **Monitor after deployment** - Watch for issues
6. **Consider immutable programs** - For production stability
7. **Use multisig for authority** - Additional security layer
8. **Verify on explorers** - Confirm deployment success

## Common Issues

| Issue | Cause | Solution |
|-------|-------|----------|
| `Insufficient funds` | Not enough SOL for deployment | Airdrop more SOL |
| `Program too large` | Program exceeds size limit | Optimize or split programs |
| `Invalid upgrade authority` | Wrong keypair | Check authority keypair |
| `Network timeout` | Network issues | Retry or switch RPC |
| `Program already deployed` | Program ID exists | Use upgrade or new ID |

## Security Considerations

### Mainnet Deployment

1. **Secure deployment keys** - Use hardware wallets or secure enclaves
2. **Multisig authority** - Require multiple signatures for upgrades
3. **Time-lock upgrades** - Give users notice before changes
4. **Audit code** - Professional security audit
5. **Test thoroughly** - Comprehensive testing on devnet
6. **Gradual rollout** - Deploy with caution
7. **Monitor for issues** - Watch program activity

### Upgrade Authority Management

```bash
# Set multisig as upgrade authority
solana program set-upgrade-authority PROGRAM_ID MULTISIG_ADDRESS

# Use hardware wallet for final approval
solana program set-upgrade-authority PROGRAM_ID --keypair /path/to/hardware/keypair.json
```

## Verifying Deployment

### On Solscan

```
https://solscan.io/account/PROGRAM_ID?cluster=devnet
```

### On Solana Beach

```
https://solanabeach.io/program/PROGRAM_ID
```

### Using CLI

```bash
# Verify program is deployed
solana program show PROGRAM_ID

# Check program data
solana account PROGRAM_ID
```

## Next Steps

- `/solana-programs` - Building programs
- `/solana-advanced` - Advanced patterns
- `/solana-core-concepts` - Understanding architecture

## Resources

- Deployment Guide: https://solana.com/docs/programs/deploying
- Anchor Deploy: https://www.anchor-lang.com/docs/deployment
- Solana CLI: https://docs.solana.com/cli
