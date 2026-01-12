# Solana Core Concepts

Understanding Solana's fundamental architecture is essential for effective development on the platform.

## Accounts Model

Solana uses a unique accounts model where all state is stored in accounts.

### Account Structure

Each account contains:
- **lamports**: Balance in lamports (1 SOL = 1,000,000,000 lamports)
- **data length**: Size of account data
- **owner**: Program that owns this account
- **executable**: Whether this account contains a program
- **rent epoch**: Next epoch when rent will be due

### Account Types

**System Accounts:** Created and owned by the System Program
- Store user funds
- Can be created by anyone

**Program Accounts:** Executable accounts containing smart contract code
- Marked as `executable: true`
- Loaded by validators when invoked

**PDAs (Program Derived Addresses):** Deterministic addresses derived from program ID and seeds
- No private key
- Used for program-controlled state

### Rent

Accounts must hold a minimum balance to avoid being garbage collected:

```rust
let minimum_balance = Rent::get()?.minimum_balance(data_size);
```

**Rent-exempt accounts:** Accounts with sufficient balance to never pay rent

## Transactions

### Transaction Structure

A Solana transaction contains:
1. **Message**: Instructions to execute
2. **Signatures**: One or more signatures

### Transaction Fees

- **Base fee**: 5000 lamports per signature
- **Priority fee**: Optional tip for faster inclusion
- **Rent**: Deducted from accounts unless rent-exempt

### Transaction Lifecycle

1. **Creation**: Build transaction with instructions
2. **Signing**: Sign with required keypairs
3. **Submission**: Send to cluster via RPC
4. **Processing**: Validators execute instructions
5. **Confirmation**: Transaction finalized

## Programs (Smart Contracts)

### Program Execution Model

**Programs are stateless** - all data stored in separate accounts
- Programs read from and write to accounts
- Multiple programs can be invoked in one transaction
- Programs can call other programs (CPI - Cross-Program Invocation)

### System Program

Native program that handles core operations:
- Creating new accounts
- Transferring SOL between accounts
- Allocating account data

Example: Creating an account
```rust
let create_account_ix = system_instruction::create_account(
    &payer.key(),
    &new_account.key(),
    minimum_balance,
    space,
    &program_id,
);
```

## Clusters

### Solana Networks

- **Devnet**: Development testing cluster
- **Testnet:** Pre-production testing cluster
- **Mainnet-Beta**: Production network with real value

### RPC Endpoints

**Official endpoints:**
- Devnet: `https://api.devnet.solana.com`
- Testnet: `https://api.testnet.solana.com`
- Mainnet: `https://api.mainnet-beta.solana.com`

### Validator Network

**Leader Schedule:** Validators take turns producing blocks
- Slot: ~400ms time period
- Epoch: ~432,000 slots (~2 days)

**Consensus:** Proof of History + Proof of Stake
- Proof of History: Cryptographic timestamp
- Proof of Stake: Validators stake SOL

## Compute Model

### Compute Units (CU)

Each transaction has a compute budget:
- **Default**: 200,000 CU
- **Maximum**: 1,400,000 CU (with request_units_heap)

### Compute Costs

Operations consume compute units:
- System calls: ~500-2,000 CU
- BPF instructions: ~1-200 CU
- CPI calls: ~5,000+ CU

### Increasing Compute Budget

```rust
use solana_program::compute_budget;

let request_units_ix = compute_budget::RequestUnits::new(
    400_000,  // units
    0,        // additional_fee
);
```

## Slots and Epochs

### Slot Time

Each slot represents a chance for a leader to produce a block:
- Target: 400ms per slot
- Not all slots produce blocks

### Epoch Structure

- **Epoch duration**: ~2 days (432,000 slots)
- **Stake rewards**: Distributed at epoch boundaries
- **Rent collection**: Occurs at epoch boundaries

## Blockhash

### Recent Blockhash

Each transaction includes a recent blockhash for:
- **Deduplication**: Prevent replay attacks
- **Expiration**: Transactions expire after ~2 minutes

### Getting Blockhash

```bash
solana blockhash
```

Or programmatically:
```rust
let recent_blockhash = rpc_client.get_latest_blockhash()?;
```

## Program Derived Addresses (PDAs)

PDAs are addresses that look like public keys but have no private keys:

### Deriving PDAs

```rust
let (pda, bump) = Pubkey::find_program_address(
    &[b"config", user_pubkey.as_ref()],
    &program_id,
);
```

### PDA Use Cases

- Configuration accounts
- User-specific data storage
- Deterministic address generation
- Enforcing program authority

## Cross-Program Invocation (CPI)

Programs can invoke other programs:

```rust
invoke(
    &system_instruction::transfer(&from, &to, amount),
    &[from.clone(), to.clone()],
);
```

### CPI Accounts

Accounts passed to CPI must match expected structure:
- Correct signer status
- Correct writability
- Correct owner program

## Key Concepts Summary

| Concept | Description |
|---------|-------------|
| **Accounts** | State storage with owner, data, and lamports |
| **Programs** | Stateless executable code |
| **Transactions** | Atomic bundle of instructions |
| **Instructions** | Single program call with accounts |
| **PDAs** | Deterministic addresses without private keys |
| **Rent** | Fee for account storage |
| **Compute** | Resource limits for transactions |
| **Slots** | Time periods (~400ms) |
| **Epochs** ~432,000 slots (~2 days) |

## Common Patterns

### Instruction Data Structure

```rust
#[derive(BorshSerialize, BorshDeserialize)]
pub struct InstructionData {
    pub amount: u64,
    pub option: u8,
}
```

### Account Validation

```rust
#[account]
pub struct MyAccount {
    pub authority: Pubkey,
    pub data: u64,
}
```

## Next Steps

- `/solana-transactions` - Building and sending transactions
- `/solana-accounts` - Advanced account management
- `/solana-programs` - Writing smart contracts

## Resources

- Solana Docs: https://solana.com/zh/docs/core
- Accounts Overview: https://solana.com/docs/core/accounts
- Transaction Overview: https://solana.com/docs/core/transactions
