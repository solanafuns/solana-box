# Deploy Solana Program Action

A reusable GitHub Action to build and deploy Solana programs to devnet, testnet, or mainnet-beta.

## Usage

### Using from Another Repository

To use this action in other projects, reference it by repository path:

```yaml
name: Deploy Solana Program

on:
  push:
    branches: [main]
  workflow_dispatch:

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Deploy Solana Program
        uses: your-username/solana-box@main  # or @v1.0.0 for a specific version
        with:
          solana_keypair: ${{ secrets.SOLANA_KEYPAIR }}
          cluster: 'devnet'
          program_path: './your-program'
```

### Basic Example (Local)

If using within the same repository:

```yaml
name: Deploy Solana Program

on:
  push:
    branches: [main]
  workflow_dispatch:

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Deploy Solana Program
        uses: ./
        with:
          solana_keypair: ${{ secrets.SOLANA_KEYPAIR }}
          cluster: 'devnet'
          program_path: './example'
```

### Advanced Example

```yaml
name: Deploy Solana Program

on:
  workflow_dispatch:
    inputs:
      cluster:
        description: 'Solana cluster'
        required: true
        default: 'devnet'
        type: choice
        options:
          - devnet
          - testnet
          - mainnet-beta

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Deploy Solana Program
        uses: ./
        with:
          solana_keypair: ${{ secrets.SOLANA_KEYPAIR }}
          program_keypair: ${{ secrets.PROGRAM_KEYPAIR }}
          cluster: ${{ github.event.inputs.cluster }}
          program_path: './example'
          program_name: 'example'
          airdrop_amount: '2'
        id: deploy
      
      - name: Use Program ID
        run: |
          echo "Program ID: ${{ steps.deploy.outputs.program_id }}"
```

## Inputs

| Input | Description | Required | Default |
|-------|-------------|----------|---------|
| `solana_keypair` | Solana deployer wallet keypair (JSON format) | Yes | - |
| `program_keypair` | Program keypair (JSON format). If not provided, a new one will be generated | No | - |
| `cluster` | Solana cluster to deploy to | No | `devnet` |
| `program_path` | Path to the Solana program directory (where Cargo.toml is located) | No | `.` |
| `program_name` | Name of the program (should match package name in Cargo.toml). If not provided, will be read from Cargo.toml | No | - |
| `solana_version` | Solana CLI version to install | No | `stable` |
| `airdrop_amount` | Amount of SOL to airdrop (only for devnet/testnet) | No | `2` |

## Outputs

| Output | Description |
|--------|-------------|
| `program_id` | The deployed program ID |
| `program_address` | The deployed program address (same as program_id) |

## Secrets

You need to set up the following secrets in your GitHub repository:

1. **SOLANA_KEYPAIR** (required): Your deployer wallet keypair in JSON format
   ```bash
   cat ~/.config/solana/id.json
   ```

2. **PROGRAM_KEYPAIR** (optional): Your program keypair in JSON format
   ```bash
   cat target/deploy/your-program-keypair.json
   ```

## How to Get Your Keypair

### Deployer Wallet Keypair

```bash
# If you don't have one, create it:
solana-keygen new

# Get the keypair content:
cat ~/.config/solana/id.json
```

### Program Keypair

```bash
# Generate a program keypair:
solana-keygen new --outfile target/deploy/your-program-keypair.json

# Get the keypair content:
cat target/deploy/your-program-keypair.json
```

## Clusters

- **devnet**: Development network (free SOL available via airdrop)
- **testnet**: Test network (free SOL available via airdrop)
- **mainnet-beta**: Main production network (requires real SOL)

## Building the Action

**Important**: Before using this action, you must build it first:

```bash
npm install
npm run build
```

This will compile the action and create the `dist/` directory with the bundled code. Make sure to commit the `dist/` folder to your repository so the action can be used.

If you modify the action code in `src/index.js`, you'll need to rebuild and commit the changes.

## License

MIT

