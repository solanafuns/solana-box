# Solana Transactions

This skill covers creating, signing, and sending transactions on the Solana blockchain.

## Transaction Basics

### Transaction Structure

A Solana transaction consists of:
- **Message**: Contains instructions
- **Signatures**: One or more cryptographic signatures

```rust
use solana_sdk::{
    transaction::Transaction,
    message::Message,
};
```

### Creating a Simple Transaction

```rust
use solana_sdk::{
    transaction::Transaction,
    system_instruction,
};

// Create a transfer instruction
let ix = system_instruction::transfer(
    &payer_pubkey,
    &recipient_pubkey,
    1_000_000, // 0.001 SOL in lamports
);

// Create transaction
let transaction = Transaction::new(
    &[&payer_keypair],
    ix,
    recent_blockhash,
);
```

## Building Transactions

### Single Instruction Transaction

```rust
use solana_client::rpc_client::RpcClient;
use solana_sdk::{
    transaction::Transaction,
    system_instruction,
};

let rpc_client = RpcClient::new("https://api.devnet.solana.com");

// Create instruction
let ix = system_instruction::transfer(
    &sender.pubkey(),
    &recipient_pubkey,
    lamports,
);

// Get recent blockhash
let recent_blockhash = rpc_client.get_latest_blockhash()?;

// Create and sign transaction
let transaction = Transaction::new_signed_with_payer(
    &[ix],
    Some(&sender.pubkey()),
    &[&sender],
    recent_blockhash,
);

// Send transaction
let signature = rpc_client.send_and_confirm_transaction(&transaction)?;
```

### Multiple Instructions Transaction

```rust
// Create multiple instructions
let instructions = vec![
    system_instruction::transfer(&payer, &recipient1, 100_000),
    system_instruction::transfer(&payer, &recipient2, 200_000),
    system_instruction::transfer(&payer, &recipient3, 300_000),
];

let transaction = Transaction::new_signed_with_payer(
    &instructions,
    Some(&payer_pubkey),
    &[&payer_keypair],
    recent_blockhash,
);
```

### Using TransactionBuilder

```rust
use solana_sdk::{
    transaction::Transaction,
    instruction::Instruction,
};

let transaction = Transaction::new_with_payer(
    &instructions,
    Some(&payer_pubkey),
);
```

## Signing Transactions

### Single Signer

```rust
let transaction = Transaction::new_signed_with_payer(
    &[instruction],
    Some(&payer_pubkey),
    &[&payer_keypair],
    recent_blockhash,
);
```

### Multiple Signers

```rust
let transaction = Transaction::new_signed_with_payer(
    &[instruction],
    Some(&payer_pubkey),
    &[&keypair1, &keypair2, &keypair3],
    recent_blockhash,
);
```

### Partial Signing

```rust
// First signer signs
let mut transaction = Transaction::new_signed_with_payer(
    &[instruction],
    Some(&payer_pubkey),
    &[&payer_keypair],
    recent_blockhash,
);

// Second signer signs later
transaction.sign(&[&authority_keypair], recent_blockhash);
```

## Sending Transactions

### Send and Wait for Confirmation

```rust
let signature = rpc_client.send_and_confirm_transaction(&transaction)?;
println!("Transaction: {}", signature);
```

### Send Without Waiting

```rust
let signature = rpc_client.send_transaction(&transaction)?;
println!("Transaction signature: {}", signature);
```

### With Timeout

```rust
use std::time::Duration;

let signature = rpc_client.send_and_confirm_transaction_with_timeout(
    &transaction,
    Duration::from_secs(60),
)?;
```

### With Commitment Level

```rust
use solana_sdk::commitment_config::CommitmentLevel;

let signature = rpc_client.send_and_confirm_transaction_with_spinner(
    &transaction,
)?;
```

## Transaction Simulation

### Simulate Transaction

```rust
let simulation_result = rpc_client.simulate_transaction(&transaction)?;

if let Some(err) = simulation_result.value.err {
    println!("Simulation error: {:?}", err);
} else {
    println!("Units consumed: {:?}", simulation_result.value.units_consumed);
}
```

### Simulate with Logs

```rust
let simulation_result = rpc_client.simulate_transaction_with_config(
    &transaction,
    RpcSimulateTransactionConfig {
        sig_verify: true,
        replace_recent_blockhash: false,
        commitment: Some(CommitmentConfig::confirmed()),
        encoding: Some(UiTransactionEncoding::Json),
        accounts: None,
        min_context_slot: None,
        inner_instructions: false,
    },
)?;
```

## Transaction Fees

### Base Fee

Every transaction pays:
- 5000 lamports per signature
- Total = 5000 × number of signers

### Priority Fees (Tips)

```rust
use solana_sdk::compute_budget::ComputeBudgetInstruction;

// Add priority fee
let priority_fee_ix = ComputeBudgetInstruction::set_compute_unit_price(1000);

let transaction = Transaction::new_signed_with_payer(
    &[priority_fee_ix, your_instruction],
    Some(&payer_pubkey),
    &[&payer_keypair],
    recent_blockhash,
);
```

### Set Compute Unit Limit

```rust
let set_units_ix = ComputeBudgetInstruction::set_compute_unit_limit(200_000);

let transaction = Transaction::new_signed_with_payer(
    &[set_units_ix, your_instruction],
    Some(&payer_pubkey),
    &[&payer_keypair],
    recent_blockhash,
);
```

### Set Compute Unit Price

```rust
let set_price_ix = ComputeBudgetInstruction::set_compute_unit_price(1000);

let transaction = Transaction::new_signed_with_payer(
    &[set_price_ix, your_instruction],
    Some(&payer_pubkey),
    &[&payer_keypair],
    recent_blockhash,
);
```

## Transaction Confirmation

### Checking Transaction Status

```rust
use solana_sdk::commitment_config::CommitmentConfig;

let status = rpc_client.get_signature_status(&signature)?;

if let Some(Ok(result)) = status {
    println!("Transaction confirmed: {:?}", result);
}
```

### Wait for Confirmation

```rust
use solana_sdk::commitment_config::CommitmentConfig;

loop {
    let status = rpc_client.get_signature_status_with_commitment(
        &signature,
        CommitmentConfig::confirmed(),
    )?;

    if let Some(result) = status {
        break result?;
    }

    std::thread::sleep(std::time::Duration::from_secs(1));
}
```

## Transaction Expiration

### Blockhash Lifespan

- Transactions expire after ~2 minutes (120 seconds)
- Expired transactions are rejected by the network

### Getting Durable Nonce

For longer-lived transactions:

```rust
use solana_sdk::system_instruction;

// Get durable nonce account
let nonce_account_pubkey = // ... your nonce account

let nonce_ix = system_instruction::advance_nonce_account(
    &nonce_account_pubkey,
    &authority_pubkey,
);

let transaction = Transaction::new_signed_with_payer(
    &[nonce_ix, your_ix],
    Some(&payer_pubkey),
    &[&payer_keypair, &authority_keypair],
    nonce_blockhash, // Use nonce blockhash instead of recent
);
```

## Error Handling

### Common Transaction Errors

| Error | Cause | Solution |
|-------|-------|----------|
| `AccountNotFound` | Account doesn't exist | Create account first |
| `InsufficientFunds` | Not enough SOL | Airdrop or transfer more SOL |
| `InvalidAccountIndex` | Wrong account order | Check instruction accounts |
| `AccountNotSigner` | Missing signature | Add signer to transaction |
| `ProgramFailedToComplete` | Program error | Check program logs |
| `BlockhashNotFound` | Old blockhash | Use recent blockhash |

### Handling Transaction Errors

```rust
match rpc_client.send_and_confirm_transaction(&transaction) {
    Ok(signature) => println!("Success: {}", signature),
    Err(err) => {
        if let solana_client::client_error::ClientErrorKind::RpcError(
            solana_sdk::transport::TransportError::TransactionError(tx_err)
        ) = err.kind {
            match tx_err {
                TransactionError::InstructionError(_, err) => {
                    println!("Instruction error: {:?}", err);
                }
                _ => println!("Transaction error: {:?}", tx_err),
            }
        }
    }
}
```

## Transaction Memo

### Adding Memo to Transaction

```rust
use solana_program::memo::MemoInstruction;

let memo_ix = MemoInstruction::new(
    &memo_pubkey,
    &[&payer_pubkey],
    "Hello Solana!".to_string(),
);

let transaction = Transaction::new_signed_with_payer(
    &[memo_ix, your_ix],
    Some(&payer_pubkey),
    &[&payer_keypair],
    recent_blockhash,
);
```

## Bulk Transactions

### Sending Multiple Transactions

```rust
let mut signatures = vec![];

for instruction in instructions {
    let transaction = Transaction::new_signed_with_payer(
        &[instruction],
        Some(&payer_pubkey),
        &[&payer_keypair],
        recent_blockhash,
    );

    let sig = rpc_client.send_transaction(&transaction)?;
    signatures.push(sig);
}

// Confirm all
for sig in signatures {
    rpc_client.confirm_transaction(&sig)?;
}
```

## CLI Usage

### Transfer via CLI

```bash
solana transfer RECIPIENT_ADDRESS 0.1
```

### With Confirmation

```bash
solana transfer RECIPIENT_ADDRESS 0.1 --confirm
```

### From File

```bash
solana transfer RECIPIENT_ADDRESS 0.1 --keypair /path/to/keypair.json
```

## Best Practices

1. **Always use recent blockhash** - Prevents transaction rejection
2. **Simulate first** - Catch errors before sending
3. **Handle errors gracefully** - Implement proper error handling
4. **Use priority fees for urgent transactions** - Faster inclusion
5. **Batch related instructions** - Reduces fees and latency
6. **Set appropriate compute limits** - Avoid running out of compute

## Next Steps

- `/solana-accounts` - Managing accounts
- `/solana-rpc-api` - RPC methods for transactions
- `/solana-programs` - Creating custom instructions

## Resources

- Transaction Docs: https://solana.com/docs/core/transactions
- Transaction Example: https://solana.com/docs/core/transactions#example
