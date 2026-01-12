# Solana RPC API

This skill covers using the Solana JSON-RPC API to interact with the blockchain.

## RPC Endpoints

### Official Endpoints

| Network | HTTP | WebSocket |
|---------|------|-----------|
| Devnet | `https://api.devnet.solana.com` | `wss://api.devnet.solana.com` |
| Testnet | `https://api.testnet.solana.com` | `wss://api.testnet.solana.com` |
| Mainnet | `https://api.mainnet-beta.solana.com` | `wss://api.mainnet-beta.solana.com` |

### Custom RPC Providers

- **QuickNode**: `https://YOUR_ENDPOINT.solana-mainnet.quiknode.pro/KEY/`
- **Alchemy**: `https://solana-mainnet.g.alchemy.com/v2/KEY`
- **Helius**: `https://rpc.helius.xyz/?api-key=KEY`
- **Triton**: `https://rpc.ankr.com/solana`

## Getting Started with RPC Client

### Rust Client

```rust
use solana_client::rpc_client::RpcClient;

// Create client
let rpc_client = RpcClient::new("https://api.devnet.solana.com");

// Or with commitment
use solana_sdk::commitment_config::CommitmentConfig;

let rpc_client = RpcClient::new_with_commitment(
    "https://api.devnet.solana.com",
    CommitmentConfig::confirmed(),
);
```

### JavaScript Client

```javascript
const { Connection } = require('@solana/web3.js');

// Create connection
const connection = new Connection(
  'https://api.devnet.solana.com',
  'confirmed'
);
```

## Account Methods

### Get Account Info

```rust
let account = rpc_client.get_account(&pubkey)?;

// Get balance
let balance = rpc_client.get_balance(&pubkey)?;

// Get multiple accounts
let accounts = rpc_client.get_multiple_accounts(&[pubkey1, pubkey2])?;
```

### JavaScript

```javascript
// Get account info
const accountInfo = await connection.getAccountInfo(publicKey);

// Get balance
const balance = await connection.getBalance(publicKey);

// Get multiple accounts
const accounts = await connection.getMultipleAccounts([
  publicKey1,
  publicKey2
]);
```

## Transaction Methods

### Send Transaction

```rust
use solana_sdk::transaction::Transaction;

let signature = rpc_client.send_transaction(&transaction)?;

// Send and confirm
let signature = rpc_client.send_and_confirm_transaction(&transaction)?;
```

### JavaScript

```javascript
// Send transaction
const signature = await connection.sendTransaction(transaction);

// Send and confirm
const signature = await connection.sendAndConfirmTransaction(
  transaction,
  [signer]
);
```

### Get Transaction

```rust
use solana_sdk::signature::Signature;

let transaction = rpc_client.get_transaction(&signature)?;

let transaction_with_meta = rpc_client.get_transaction_with_meta(&signature)?;
```

### JavaScript

```javascript
const tx = await connection.getTransaction(signature);

const txWithMeta = await connection.getTransaction(signature, {
  maxSupportedTransactionVersion: 0
});
```

## Block and Slot Methods

### Get Latest Blockhash

```rust
let blockhash = rpc_client.get_latest_blockhash()?;
```

### Get Slot

```rust
let slot = rpc_client.get_slot()?;
```

### Get Block

```rust
use solana_sdk::commitment_config::CommitmentConfig;

let block = rpc_client.get_block(slot, RpcBlockConfig {
  encoding: Some(UiTransactionEncoding::Json),
  transaction_details: Some(TransactionDetails::Full),
  rewards: Some(true),
  ..Default::default()
})?;
```

### Get Blocks

```rust
let blocks = rpc_client.get_blocks(start_slot)?;
```

### JavaScript

```javascript
// Get latest blockhash
const blockhash = await connection.getLatestBlockhash();

// Get current slot
const slot = await connection.getSlot();

// Get block
const block = await connection.getBlock(slot, {
  maxSupportedTransactionVersion: 0
});
```

## Program Methods

### Get Program Account

```rust
let account = rpc_client.get_account(&program_id)?;
```

### Get Program Accounts

```rust
let accounts = rpc_client.get_program_accounts(&program_id)?;
```

### With Filters

```rust
use solana_client::rpc_filter::{RpcFilterType, Memcmp};

let filters = vec![
  RpcFilterType::Memcmp(Memcmp::new(
    0,
    MemcmpEncodedBytes::Base58("some_value".to_string())
  )),
];

let accounts = rpc_client.get_program_accounts_with_filter(
  &program_id,
  filters
)?;
```

### JavaScript

```javascript
// Get all program accounts
const accounts = await connection.getProgramAccounts(programId);

// With filters
const accounts = await connection.getProgramAccounts(
  programId,
  {
    filters: [
      {
        memcmp: {
          offset: 0,
          bytes: 'some_value'
        }
      }
    ]
  }
);
```

## Subscription Methods (WebSocket)

### Subscribe to Account Changes

```rust
use solana_client::rpc_client::RpcClient;
use solana_client::rpc_subscription::RpcSubscription;

let (mut subscription_client, receiver) = RpcClient::subscription_sender(
  "wss://api.devnet.solana.com"
)?;

let subscription = subscription_client.account_subscribe(
  &pubkey,
  RpcAccountInfoConfig {
    encoding: Some(UiAccountEncoding::Base64),
    ..Default::default()
  }
)?;

// Receive updates
for message in receiver {
  match message {
    RpcSubscription::Account(account) => {
      println!("Account updated: {:?}", account);
    }
    _ => {}
  }
}
```

### JavaScript

```javascript
// Subscribe to account changes
const subscriptionId = connection.onAccountChange(
  publicKey,
  (accountInfo) => {
    console.log('Account updated:', accountInfo);
  },
  'confirmed'
);

// Unsubscribe
connection.removeAccountChangeListener(subscriptionId);
```

### Subscribe to Logs

```javascript
// Subscribe to program logs
const subscriptionId = connection.onLogs(
  programId,
  (logs) => {
    console.log('Logs:', logs);
  },
  'confirmed'
);
```

### Subscribe to Signatures

```javascript
// Subscribe to signature notifications
const subscriptionId = connection.onSignature(
  signature,
  (result) => {
    console.log('Transaction result:', result);
  },
  'confirmed'
);
```

## Health and Version Methods

### Get Health

```rust
let health = rpc_client.get_health()?;
```

### Get Version

```rust
let version = rpc_client.get_version()?;
```

### JavaScript

```javascript
// Get health
await connection.getHealth();

// Get version
const version = await connection.getVersion();
```

## Token Methods

### Get Token Supply

```rust
let supply = rpc_client.get_token_supply(&mint_pubkey)?;
```

### Get Token Account Balance

```rust
let balance = rpc_client.get_token_account_balance(&token_account_pubkey)?;
```

### JavaScript

```javascript
// Get token supply
const supply = await connection.getTokenSupply(mintPubkey);

// Get token account balance
const balance = await connection.getTokenAccountBalance(
  tokenAccountPubkey
);
```

## Configuration Methods

### Get Minimum Balance for Rent Exemption

```rust
let balance = rpc_client.get_minimum_balance_for_rent_exemption(data_size)?;
```

### Get Recent Blockhash

```rust
let blockhash = rpc_client.get_recent_blockhash()?;
```

### JavaScript

```javascript
// Get rent exemption
const balance = await connection.getMinimumBalanceForRentExemption(100);

// Get recent blockhash
const blockhash = await connection.getRecentBlockhash();
```

## Advanced Methods

### Simulate Transaction

```rust
let result = rpc_client.simulate_transaction(&transaction)?;

println!("Units consumed: {:?}", result.value.units_consumed);
println!("Logs: {:?}", result.value.logs);
```

### JavaScript

```javascript
const result = await connection.simulateTransaction(transaction);

console.log('Units consumed:', result.value.unitsConsumed);
console.log('Logs:', result.value.logs);
```

### Get Stake Activation

```rust
let activation = rpc_client.get_stake_activation(&stake_pubkey)?;
```

### Get Vote Accounts

```rust
let vote_accounts = rpc_client.get_vote_accounts()?;
```

### JavaScript

```javascript
// Get vote accounts
const voteAccounts = await connection.getVoteAccounts();
```

## Batch Requests

### Multiple Requests

```rust
let req1 = RpcRequest::new("getAccount", json!({"pubkey": pubkey1}));
let req2 = RpcRequest::new("getAccount", json!({"pubkey": pubkey2}));

let responses = rpc_client.send_batch(vec![req1, req2])?;
```

### JavaScript

```javascript
const results = await connection.getMultipleAccountsInfo([
  pubkey1,
  pubkey2,
  pubkey3
]);
```

## Error Handling

### Common RPC Errors

| Error Code | Description |
|------------|-------------|
| -32001 | Block not found |
| -32002 | Transaction not found |
| -32003 | Invalid parameter |
| -32004 | Account not found |
| -32005 | Method not found |
| -32007 | Slot skipped |
| -32009 | Node unhealthy |

### Handling Errors

```rust
use solana_client::client_error::ClientError;

match rpc_client.send_transaction(&transaction) {
    Ok(signature) => println!("Success: {}", signature),
    Err(ClientError::RpcError(RpcError::ForUser(msg))) => {
        println!("RPC Error: {}", msg);
    }
    Err(err) => println!("Error: {:?}", err),
}
```

### JavaScript

```javascript
try {
  const signature = await connection.sendTransaction(transaction);
  console.log('Success:', signature);
} catch (err) {
  console.error('Error:', err.message);
}
```

## Commitment Levels

### Commitment Levels

| Level | Description |
|-------|-------------|
| `processed` | Transaction processed by node |
| `confirmed` | Transaction reached consensus |
| `finalized` | Transaction finalized |

### Using Commitment

```rust
use solana_sdk::commitment_config::CommitmentConfig;

let config = RpcAccountInfoConfig {
  commitment: Some(CommitmentConfig::confirmed()),
  ..Default::default()
};

let account = rpc_client.get_account_with_config(&pubkey, config)?;
```

### JavaScript

```javascript
const account = await connection.getAccountInfo(
  publicKey,
  { commitment: 'confirmed' }
);
```

## Rate Limiting

### Best Practices

1. **Batch requests** - Send multiple requests together
2. **Use WebSocket subscriptions** - For real-time updates
3. **Cache responses** - Store frequently accessed data
4. **Use commitment levels** - Lower commitment for faster responses

### Rate Limit Handling

```rust
use std::time::Duration;

// Add delay between requests
std::thread::sleep(Duration::from_millis(100));
```

### JavaScript

```javascript
// Add delay between requests
await new Promise(resolve => setTimeout(resolve, 100));
```

## CLI Usage

### curl Examples

```bash
# Get account info
curl -X POST -H "Content-Type: application/json" \
  -d '{"jsonrpc":"2.0","id":1,"method":"getAccountInfo","params":["PUBLIC_KEY"]}' \
  https://api.devnet.solana.com

# Get balance
curl -X POST -H "Content-Type: application/json" \
  -d '{"jsonrpc":"2.0","id":1,"method":"getBalance","params":["PUBLIC_KEY"]}' \
  https://api.devnet.solana.com

# Get slot
curl -X POST -H "Content-Type: application/json" \
  -d '{"jsonrpc":"2.0","id":1,"method":"getSlot"}' \
  https://api.devnet.solana.com
```

## Best Practices

1. **Use appropriate commitment levels** - Balance speed and finality
2. **Implement retry logic** - Handle network issues
3. **Use subscriptions for monitoring** - Reduce polling
4. **Batch requests when possible** - Reduce API calls
5. **Handle errors gracefully** - Provide fallbacks
6. **Monitor rate limits** - Avoid throttling

## Next Steps

- `/solana-transactions` - Building transactions
- `/solana-accounts` - Account querying
- `/solana-front-end` - Frontend integration

## Resources

- RPC API Docs: https://solana.com/zh/docs/rpc
- RPC Methods: https://solana.com/docs/rpc
