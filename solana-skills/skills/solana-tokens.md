# Solana Tokens (SPL Token)

This skill covers working with SPL Tokens on Solana, including creating mints, token accounts, and token operations.

## SPL Token Program

The SPL Token Program (`TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA`) is the standard for creating and managing tokens on Solana.

## Token Types

### Token Mint

Defines the token type and properties:
- Total supply
- Decimals
- Authority controls
- Freeze authority

### Token Account

Holds tokens of a specific mint:
- Owner
- Mint address
- Balance
- Delegate authority

## Creating a Token Mint

### Using CLI

```bash
# Create a new token mint
spl-token create-token

# Create with decimals
spl-token create-token --decimals 9

# Output: Token Mint: YOUR_MINT_ADDRESS
```

### Using JavaScript

```javascript
const { Token, TOKEN_PROGRAM_ID } = require('@solana/spl-token');
const { Keypair, Connection } = require('@solana/web3.js');

const connection = new Connection('https://api.devnet.solana.com');
const payer = Keypair.generate(); // Your payer keypair

// Create new mint
const mint = await Token.createMint(
  connection,
  payer,           // Payer
  payer.publicKey, // Mint authority
  null,            // Freeze authority (optional)
  9                // Decimals
);

console.log('Mint address:', mint.publicKey.toBase58());
```

### Using Rust

```rust
use spl_token::{
    instruction::{initialize_mint, initialize_mint2},
    state::Mint,
};

let mint_keypair = Keypair::new();
let rent = Rent::get()?;
let mint_rent = rent.minimum_balance(Mint::LEN());

// Create account
let create_account_ix = system_instruction::create_account(
    &payer_pubkey,
    &mint_keypair.pubkey(),
    mint_rent,
    Mint::LEN as u64,
    &spl_token::id(),
);

// Initialize mint
let init_mint_ix = initialize_mint(
    &spl_token::id(),
    &mint_keypair.pubkey(),
    &mint_authority_pubkey,
    Some(&freeze_authority_pubkey),
    9, // Decimals
)?;
```

## Creating Token Account

### Associated Token Account (Recommended)

Associated Token Accounts (ATA) are deterministic addresses for token accounts.

```bash
# Create ATA
spl-token create-account YOUR_MINT_ADDRESS

# Or with specific wallet
spl-token create-account YOUR_MINT_ADDRESS --owner WALLET_ADDRESS
```

```javascript
const { getOrCreateAssociatedTokenAccount } = require('@solana/spl-token');

const ata = await getOrCreateAssociatedTokenAccount(
  connection,
  payer,           // Payer
  mint,            // Mint
  owner,           // Owner
  false            // Allow owner off-curve
);

console.log('ATA address:', ata.address.toBase58());
```

### Manual Token Account

```javascript
const { Account, TOKEN_PROGRAM_ID } = require('@solana/spl-token');

const tokenAccount = await Account.create(
  connection,
  payer,           // Payer
  mint.publicKey,  // Mint
  owner            // Owner
);
```

## Minting Tokens

### CLI

```bash
# Mint tokens to your account
spl-token mint YOUR_MINT_ADDRESS 1000

# Mint to specific account
spl-token mint YOUR_MINT_ADDRESS 1000 RECIPIENT_TOKEN_ACCOUNT
```

### JavaScript

```javascript
const { mintTo } = require('@solana/spl-token');

await mintTo(
  connection,
  payer,           // Payer
  mint,            // Mint
  ata,             // Destination account
  mintAuthority,   // Mint authority
  1000 * 10**9     // Amount (with decimals)
);
```

### Rust

```rust
use spl_token::instruction::mint_to;

let mint_to_ix = mint_to(
    &spl_token::id(),
    &mint_pubkey,
    &token_account_pubkey,
    &mint_authority_pubkey,
    &[],
    1000 * 10**9, // Amount with decimals
)?;
```

## Transferring Tokens

### CLI

```bash
# Transfer tokens
spl-token transfer YOUR_MINT_ADDRESS 100 RECIPIENT_ADDRESS

# Transfer with specific account
spl-token transfer YOUR_MINT_ADDRESS 100 RECIPIENT_TOKEN_ACCOUNT
```

### JavaScript

```javascript
const { createTransferInstruction } = require('@solana/spl-token');

const transferIx = createTransferInstruction(
  sourceAta,      // Source
  destinationAta, // Destination
  owner,          // Owner
  100 * 10**9,    // Amount
  [],
  TOKEN_PROGRAM_ID
);

// Add to transaction and send
```

### Rust

```rust
use spl_token::instruction::transfer;

let transfer_ix = transfer(
    &spl_token::id(),
    &source_pubkey,
    &destination_pubkey,
    &owner_pubkey,
    &[],
    100 * 10**9,
)?;
```

## Token Approvals and Delegates

### Approve Delegate

```bash
# Approve delegate to spend tokens
spl-token approve YOUR_TOKEN_ACCOUNT 100 DELEGATE_ADDRESS
```

```javascript
const { createApproveInstruction } = require('@solana/spl-token');

const approveIx = createApproveInstruction(
  ata,
  delegate,
  owner,
  100 * 10**9,
  [],
  TOKEN_PROGRAM_ID
);
```

### Revoke Delegate

```bash
# Revoke delegate
spl-token revoke YOUR_TOKEN_ACCOUNT
```

```javascript
const { createRevokeInstruction } = require('@solana/spl-token');

const revokeIx = createRevokeInstruction(
  ata,
  owner,
  [],
  TOKEN_PROGRAM_ID
);
```

## Burning Tokens

### CLI

```bash
# Burn tokens
spl-token burn YOUR_TOKEN_ACCOUNT 100
```

### JavaScript

```javascript
const { createBurnInstruction } = require('@solana/spl-token');

const burnIx = createBurnInstruction(
  ata,
  mint,
  owner,
  100 * 10**9,
  [],
  TOKEN_PROGRAM_ID
);
```

### Rust

```rust
use spl_token::instruction::burn;

let burn_ix = burn(
    &spl_token::id(),
    &token_account_pubkey,
    &mint_pubkey,
    &owner_pubkey,
    &[],
    100 * 10**9,
)?;
```

## Token Metadata (Metaplex)

For NFTs and tokens with metadata, use the Metaplex Token Metadata program.

### Creating NFT with Metadata

```javascript
const {
  metadata: { Metadata, DataV2 }
} = require('@metaplex-foundation/mpl-token-metadata');
const {
  createCreateMetadataAccountV3Instruction
} = require('@metaplex-foundation/mpl-token-metadata');

const metadataData = new DataV2({
  name: 'My NFT',
  symbol: 'MNFT',
  uri: 'https://example.com/metadata.json',
  sellerFeeBasisPoints: 500,
  creators: null,
  collection: null,
  uses: null
});

const createMetadataIx = createCreateMetadataAccountV3Instruction(
  {
    metadata: metadataPda,
    mint: mint.publicKey,
    mintAuthority: mintAuthority,
    payer: payer.publicKey,
    updateAuthority: updateAuthority,
  },
  {
    createMetadataAccountArgsV3: {
      data: metadataData,
      isMutable: true,
      collectionDetails: null
    }
  }
);
```

## Token Multi-Signature

### Creating Multi-Sig Mint Authority

```javascript
const { createMultisig } = require('@solana/spl-token');

const multisig = await createMultisig(
  connection,
  payer,
  [
    signer1.publicKey,
    signer2.publicKey,
    signer3.publicKey
  ],
  2 // Signatures required
);
```

### Using Multi-Sig

```javascript
// Mint with multi-sig authority
const mintToIx = createMintToInstruction({
  mint,
  destination: ata,
  authority: multisig,
  multiSigners: [signer1, signer2],
  amount: 1000,
});
```

## Token Freeze and Thaw

### Freeze Token Account

```bash
# Freeze account (requires freeze authority)
spl-token freeze TOKEN_ACCOUNT
```

```javascript
const { createFreezeAccountInstruction } = require('@solana/spl-token');

const freezeIx = createFreezeAccountInstruction(
  tokenAccount,
  mint,
  freezeAuthority,
  [],
  TOKEN_PROGRAM_ID
);
```

### Thaw Token Account

```bash
# Thaw account
spl-token thaw TOKEN_ACCOUNT
```

## Querying Token Information

### Get Token Supply

```javascript
const supply = await connection.getTokenSupply(mint);
console.log('Total supply:', supply.value);
```

### Get Token Account Balance

```javascript
const balance = await connection.getTokenAccountBalance(ata);
console.log('Balance:', balance.value);
```

### Get Token Account Info

```javascript
const accountInfo = await connection.getAccountInfo(ata);
// Parse Token account structure
```

## Token-2022 (New Token Standard)

Solana has introduced Token-2022, an updated token program with additional features.

### Using Token-2022

```javascript
const { TOKEN_2022_PROGRAM_ID } = require('@solana/spl-token');

// Use TOKEN_2022_PROGRAM_ID instead of TOKEN_PROGRAM_ID
const mint = await createMint(
  connection,
  payer,
  mintAuthority,
  freezeAuthority,
  9,
  undefined,
  undefined,
  TOKEN_2022_PROGRAM_ID
);
```

### Token-2022 Features

- Interest-bearing tokens
- Transfer fees
- Confidential transfers
- Non-transferable tokens
- Required memo on transfer

## Best Practices

1. **Use Associated Token Accounts** - Simpler address derivation
2. **Check decimals before operations** - Avoid amount errors
3. **Validate mint addresses** - Prevent token confusion
4. **Handle re-allocations** - Token accounts may need more space
5. **Use Token-2022 for new projects** - Additional features
6. **Test on devnet first** - Verify token operations
7. **Keep mint authority secure** - Protect against unauthorized minting
8. **Document your token** - Clear metadata for users

## Common Issues

| Issue | Cause | Solution |
|-------|-------|----------|
| `NoTokenAccount` | Token account doesn't exist | Create ATA first |
| `OwnerMismatch` | Wrong owner for token account | Verify owner address |
| `InsufficientFunds` | Not enough tokens | Check balance before transfer |
| `MintMismatch` | Wrong mint for account | Use correct mint address |
| `Frozen` | Account is frozen | Thaw account first |

## CLI Reference

### Common Commands

```bash
# List all tokens
spl-token accounts

# Get token balance
spl-token balance YOUR_MINT_ADDRESS

# Get token supply
spl-token supply YOUR_MINT_ADDRESS

# Show token account info
spl-token account-info TOKEN_ACCOUNT_ADDRESS

# Close token account
spl-token close TOKEN_ACCOUNT_ADDRESS

# Set authority
spl-token authorize YOUR_MINT_ADDRESS mint-authority NEW_AUTHORITY
```

## Next Steps

- `/solana-nfts` - Creating NFTs
- `/solana-front-end` - Wallet integration
- `/solana-advanced` - Advanced token patterns

## Resources

- SPL Token: https://solana.com/docs/core/tokens
- Token Cookbook: https://solanacookbook.com/references/token.html
- Metaplex Docs: https://docs.metaplex.com/programs/token-metadata
