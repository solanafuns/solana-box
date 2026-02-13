# Solana Accounts

This skill covers managing accounts on Solana, including creating, reading, and modifying accounts.

## Account Basics

### Account Structure

Every Solana account has:
- **lamports**: Balance (1 SOL = 1,000,000,000 lamports)
- **data**: Binary data payload
- **owner**: Program that owns this account
- **executable**: Whether this account contains a program
- **rent_epoch**: Next epoch when rent is due

```rust
use solana_sdk::account::Account;

let account = Account {
    lamports: 1_000_000_000,  // 1 SOL
    data: vec![],
    owner: system_program::id(),
    executable: false,
    rent_epoch: 0,
};
```

## Creating Accounts

### Using System Program

```rust
use solana_sdk::system_instruction;
use solana_sdk::pubkey::Pubkey;

// Create account instruction
let create_ix = system_instruction::create_account(
    &payer_pubkey,           // From
    &new_account_pubkey,     // To
    1_000_000_000,           // Lamports (rent-exempt balance)
    100,                     // Space (data size)
    &program_id,             // Owner
);

let transaction = Transaction::new_signed_with_payer(
    &[create_ix],
    Some(&payer_pubkey),
    &[&payer_keypair, &new_account_keypair],
    recent_blockhash,
);
```

### Creating with Seed

```rust
use solana_sdk::system_instruction;

let seed = b"my_seed";
let (pda, bump) = Pubkey::find_program_address(
    &[seed],
    &program_id,
);

let create_with_seed_ix = system_instruction::create_account_with_seed(
    &payer_pubkey,
    &pda,
    &payer_pubkey,     // Base
    seed,              // Seed
    1_000_000_000,     // Lamports
    100,               // Space
    &program_id,
);
```

### Allocate Space for Existing Account

```rust
let allocate_ix = system_instruction::allocate(
    &account_pubkey,
    100,  // Space
);

let assign_ix = system_instruction::assign(
    &account_pubkey,
    &program_id,
);

let transaction = Transaction::new_signed_with_payer(
    &[allocate_ix, assign_ix],
    Some(&payer_pubkey),
    &[&account_keypair],
    recent_blockhash,
);
```

## Account Rent

### Calculate Rent-Exempt Balance

```rust
use solana_sdk::rent::Rent;
use solana_client::rpc_client::RpcClient;

let rpc_client = RpcClient::new("https://api.devnet.solana.com");

// Get rent structure
let rent = rpc_client.get_minimum_balance_for_rent_exemption(100)?;

println!("Rent-exempt balance for 100 bytes: {} lamports", rent);
```

### Rent Exemption

```rust
// Check if account is rent exempt
let account = rpc_client.get_account(&account_pubkey)?;
let rent = Rent::get()?;

if rent.is_exempt(account.lamports, account.data.len()) {
    println!("Account is rent-exempt");
}
```

## Reading Account Data

### Get Account Info

```rust
use solana_client::rpc_client::RpcClient;

let rpc_client = RpcClient::new("https://api.devnet.solana.com");

let account = rpc_client.get_account(&account_pubkey)?;

println!("Balance: {} lamports", account.lamports);
println!("Owner: {}", account.owner);
println!("Data length: {}", account.data.len());
println!("Executable: {}", account.executable);
```

### Get Multiple Accounts

```rust
let pubkeys = vec![pubkey1, pubkey2, pubkey3];
let accounts = rpc_client.get_multiple_accounts(&pubkeys)?;

for (i, account) in accounts.iter().enumerate() {
    if let Some(acc) = account {
        println!("Account {}: {} lamports", i, acc.lamports);
    }
}
```

### Parse Custom Account Data

```rust
use borsh::{BorshDeserialize, BorshSerialize};

#[derive(BorshSerialize, BorshDeserialize, Debug)]
pub struct MyAccount {
    pub authority: Pubkey,
    pub counter: u64,
    pub flag: bool,
}

let account = rpc_client.get_account(&account_pubkey)?;
let my_account = MyAccount::try_from_slice(&account.data)?;

println!("Authority: {}", my_account.authority);
println!("Counter: {}", my_account.counter);
```

## Modifying Account Data

### Writing to Account Data

```rust
// In your program
#[derive(BorshSerialize, BorshDeserialize)]
pub struct MyAccount {
    pub data: u64,
}

pub fn update_account(ctx: Context<Update>, new_data: u64) -> Result<()> {
    let account = &mut ctx.accounts.my_account;
    account.data = new_data;
    Ok(())
}
```

### Resizing Account Data

To resize account data, you must:
1. Create a new account with the desired size
2. Copy data from old to new
3. Close the old account

```rust
let new_size = 200;
let rent = Rent::get()?;
let new_balance = rent.minimum_balance(new_size);

// Create new account
let create_new_ix = system_instruction::create_account(
    &payer_pubkey,
    &new_account_pubkey,
    new_balance,
    new_size,
    &program_id,
);

// Transfer lamports and close old account
let transfer_ix = system_instruction::transfer(
    &old_account_pubkey,
    &new_account_pubkey,
    old_account.lamports,
);

let close_ix = system_instruction::close_account(
    &old_account_pubkey,
    &payer_pubkey,
);
```

## Program Derived Addresses (PDAs)

### Finding PDA

```rust
use solana_sdk::pubkey::Pubkey;

let seeds = &[b"config", authority_pubkey.as_ref()];
let (pda, bump) = Pubkey::find_program_address(seeds, &program_id);

println!("PDA: {}", pda);
println!("Bump seed: {}", bump);
```

### Creating PDA Account

```rust
let seeds = &[b"vault", authority_pubkey.as_ref()];
let (pda, bump) = Pubkey::find_program_address(seeds, &program_id);

// Create account via CPI in program
invoke_signed(
    &system_instruction::create_account(
        &payer.pubkey(),
        &pda,
        rent_lamports,
        data_size,
        &program_id,
    ),
    &[
        payer.to_account_info(),
        pda.to_account_info(),
    ],
    &[&[
        b"vault",
        authority_pubkey.as_ref(),
        &[bump],
    ]],
)?;
```

### Validating PDA

```rust
pub fn validate_pda(
    pda: &Pubkey,
    seeds: &[&[u8]],
    program_id: &Pubkey,
) -> bool {
    let (expected_pda, _bump) = Pubkey::find_program_address(seeds, program_id);
    pda == &expected_pda
}
```

## Associated Token Accounts

### Find Associated Token Account

```rust
use spl_associated_token_account::get_associated_token_address;

let ata = get_associated_token_address(
    &wallet_pubkey,
    &mint_pubkey,
);

println!("Associated Token Account: {}", ata);
```

### Create Associated Token Account

```rust
use spl_associated_token_account::instruction::create_associated_token_account;

let create_ata_ix = create_associated_token_account(
    &payer_pubkey,
    &wallet_pubkey,
    &mint_pubkey,
    &spl_token::id(),
);
```

## Closing Accounts

### Close Account

```rust
use solana_sdk::system_instruction;

let close_ix = system_instruction::close_account(
    &account_pubkey,
    &recipient_pubkey,
);

let transaction = Transaction::new_signed_with_payer(
    &[close_ix],
    Some(&payer_pubkey),
    &[&account_keypair],
    recent_blockhash,
);
```

### Transfer Lamports Before Closing

```rust
// Transfer lamports
let transfer_ix = system_instruction::transfer(
    &account_pubkey,
    &recipient_pubkey,
    account.lamports,
);

// Close account
let close_ix = system_instruction::close_account(
    &account_pubkey,
    &recipient_pubkey,
);
```

## Account Metadata

### Account Size Calculation

```rust
// Calculate account size
use std::mem;

#[derive(BorshSerialize, BorshDeserialize)]
pub struct MyData {
    pub field1: u64,        // 8 bytes
    pub field2: [u8; 32],   // 32 bytes
    pub field3: Pubkey,     // 32 bytes
    pub field4: bool,       // 1 byte
}

let size = mem::size_of::<MyData>();
println!("Account size: {} bytes", size);
```

### Adding Discriminator (Anchor)

```rust
// Anchor adds 8-byte discriminator
const DISCRIMINATOR_SIZE: usize = 8;

let total_size = DISCRIMINATOR_SIZE + mem::size_of::<MyData>();
```

## Account Queries

### Get Program Accounts

```rust
use solana_client::rpc_client::RpcClient;
use solana_client::rpc_config::{RpcProgramAccountsConfig, RpcAccountInfoConfig};

let rpc_client = RpcClient::new("https://api.devnet.solana.com");

let accounts = rpc_client.get_program_accounts(&program_id)?;

for (pubkey, account) in accounts {
    println!("Account: {}", pubkey);
    println!("Balance: {}", account.lamports);
}
```

### With Filters

```rust
let config = RpcProgramAccountsConfig {
    account_filter: Some(RpcAccountInfoConfig {
        encoding: Some(UiAccountEncoding::Base64),
        ..Default::default()
    }),
    ..Default::default()
};

let accounts = rpc_client.get_program_accounts_with_config(&program_id, config)?;
```

### Filter by Data Size

```rust
use solana_client::rpc_filter::{RpcFilterType, Memcmp};

let filters = vec![
    RpcFilterType::Memcmp(Memcmp::new(
        0,  // Offset
        MemcmpEncodedBytes::Bytes([1, 2, 3, 4].to_vec()),
    )),
];

let accounts = rpc_client.get_program_accounts_with_filter(
    &program_id,
    filters,
)?;
```

## Account Security

### Checking Account Owner

```rust
if account.owner != program_id {
    return Err(ProgramError::IncorrectProgramId);
}
```

### Validating Signer

```rust
if !account.is_signer {
    return Err(ProgramError::MissingRequiredSignature);
}
```

### Checking Writable

```rust
if !account.is_writable {
    return Err(ProgramError::InvalidAccountData);
}
```

## CLI Usage

### Create Account

```bash
solana-keygen new -o my_account.json
solana-create-account my_account.json --owner PROGRAM_ID 100
```

### Get Account Info

```bash
solana-account ACCOUNT_ADDRESS
```

### Get Balance

```bash
solana balance ACCOUNT_ADDRESS
```

## Best Practices

1. **Always make accounts rent-exempt** - Prevents garbage collection
2. **Use PDAs for program-controlled state** - No private keys to manage
3. **Validate all accounts** - Check ownership, signer status, writability
4. **Close unused accounts** - Recover lamports
5. **Use associated token accounts** - Deterministic token account addresses
6. **Document account structure** - Clear data layout for users

## Next Steps

- `/solana-programs` - Managing accounts in programs
- `/solana-tokens` - Token accounts
- `/solana-rpc-api` - Account querying methods

## Resources

- Account Docs: https://solana.com/docs/core/accounts
- Account Management: https://solana.com/docs/core/accounts#managing-accounts
- PDAs: https://solana.com/docs/core/cpi#program-derived-addresses
