# Solana Advanced Topics

This skill covers advanced Solana development patterns and techniques.

## Advanced Account Patterns

### Concurrent Account Management

```rust
use std::collections::HashMap;

pub struct AccountManager {
    accounts: HashMap<Pubkey, AccountInfo>,
}

impl AccountManager {
    pub fn validate_concurrent_access(
        &self,
        accounts: &[AccountInfo]
    ) -> Result<()> {
        // Check for duplicate accounts
        let unique: std::collections::HashSet<_> =
            accounts.iter().map(|a| a.key).collect();

        if unique.len() != accounts.len() {
            return Err(ProgramError::InvalidArgument);
        }

        // Check for writability conflicts
        for account in accounts {
            if account.is_writable && !account.is_signer {
                // Validate writable access
            }
        }

        Ok(())
    }
}
```

### Account Reallocations

```rust
// In your program
pub fn realloc_account(
    ctx: Context<Realloc>,
    new_size: usize
) -> Result<()> {
    let account = &ctx.accounts.account;
    let rent = Rent::get()?;

    // Calculate new rent-exempt balance
    let new_balance = rent.minimum_balance(new_size);

    // Transfer additional lamports if needed
    if new_balance > account.lamports() {
        let diff = new_balance - account.lamports();
        transfer(
            &ctx.accounts.payer.to_account_info(),
            &account.to_account_info(),
            diff,
        )?;
    }

    // Reallocate account
    account.realloc(new_size, false)?;

    Ok(())
}
```

## Cross-Program Invocation (CPI) Patterns

### Dynamic CPI

```rust
pub fn call_external_program(
    ctx: Context<ExternalCall>,
    program_id: Pubkey,
    instruction_data: Vec<u8>
) -> Result<()> {
    let accounts = vec![
        AccountMeta::new_readonly(
            ctx.accounts.system_program.key(),
            false
        ),
        AccountMeta::new(ctx.accounts.target.key(), true),
    ];

    let instruction = Instruction::new_with_bytes(
        program_id,
        &instruction_data,
        accounts,
    );

    invoke(&instruction, ctx.accounts.as_ref())?;

    Ok(())
}
```

### CPI with Return Data

```rust
use solana_program::program::invoke_return_data;

pub fn cpi_with_return_data(
    ctx: Context<CallWithReturn>
) -> Result<()> {
    let instruction = create_instruction();

    invoke_return_data(
        &instruction,
        ctx.accounts.as_ref()
    )?;

    // Read return data
    let return_data = solana_program::program::get_return_data();
    if let Some((program_id, data)) = return_data {
        msg!("Return data from {}: {:?}", program_id, data);
    }

    Ok(())
}
```

### CPI with Custom Accounts

```rust
pub fn complex_cpi(
    ctx: Context<ComplexCPI>,
    amount: u64
) -> Result<()> {
    // Create instruction for external program
    let instruction = Instruction {
        program_id: *ctx.accounts.external_program.key,
        accounts: vec![
            AccountMeta::new_readonly(
                ctx.accounts.authority.key(),
                true
            ),
            AccountMeta::new(ctx.accounts.vault.key(), false),
            AccountMeta::new_readonly(
                ctx.accounts.token_program.key(),
                false
            ),
        ],
        data: amount.to_le_bytes().to_vec(),
    };

    invoke(&instruction, ctx.accounts.as_ref())?;

    Ok(())
}
```

## PDA Patterns

### Multi-Signature PDA

```rust
pub fn create_multisig_pda(
    ctx: Context<CreateMultisig>,
    owners: Vec<Pubkey>,
    threshold: u8
) -> Result<()> {
    let seeds = &[
        b"multisig",
        ctx.accounts.config.key().as_ref(),
        &owners.len().to_le_bytes(),
    ];

    let (pda, bump) = Pubkey::find_program_address(
        seeds,
        ctx.program_id
    );

    // Create and validate PDA
    invoke_signed(
        &system_instruction::create_account(
            ctx.accounts.payer.key,
            &pda,
            rent_lamports,
            size,
            ctx.program_id,
        ),
        &[ctx.accounts.payer.to_account_info()],
        &[seeds, &[bump.to_le()]],
    )?;

    Ok(())
}
```

### PDA Collections

```rust
pub fn derive_collection_pdas(
    program_id: &Pubkey,
    collection: &Pubkey,
    count: usize
) -> Vec<(Pubkey, u8)> {
    (0..count)
        .map(|i| {
            Pubkey::find_program_address(
                &[
                    b"collection",
                    collection.as_ref(),
                    &i.to_le_bytes(),
                ],
                program_id
            )
        })
        .collect()
}
```

## Memory Management

### Efficient Data Structures

```rust
#[derive(BorshSerialize, BorshDeserialize)]
pub struct EfficientState {
    // Use fixed-size arrays instead of Vec when possible
    pub items: [u64; 10],
    pub count: u8,

    // Bit flags for boolean values
    pub flags: u8,
}

impl EfficientState {
    pub fn is_active(&self) -> bool {
        self.flags & 1 != 0
    }

    pub fn set_active(&mut self, active: bool) {
        if active {
            self.flags |= 1;
        } else {
            self.flags &= !1;
        }
    }
}
```

### Account Size Optimization

```rust
use std::mem;

pub fn calculate_account_size<T>() -> usize {
    // Account discriminator (8 bytes for Anchor)
    8 + mem::size_of::<T>()
}

// Example usage
const MAX_ITEMS: usize = 100;

#[account]
pub struct OptimizedAccount {
    pub items: Vec<u8>,  // Use Vec for variable data
}

impl OptimizedAccount {
    pub fn required_space() -> usize {
        8 + 4 + (MAX_ITEMS * mem::size_of::<u8>())
    }
}
```

## Error Handling

### Custom Error Types

```rust
#[error_code]
pub enum AdvancedErrorCode {
    #[msg("Insufficient liquidity")]
    InsufficientLiquidity,

    #[msg("Slippage tolerance exceeded")]
    SlippageExceeded,

    #[msg("Invalid oracle price")]
    InvalidOraclePrice,

    #[msg("Math operation overflow")]
    MathOverflow,
}

// Usage in instruction
pub fn swap(
    ctx: Context<Swap>,
    amount_in: u64,
    minimum_out: u64
) -> Result<()> {
    let amount_out = calculate_amount_out(amount_in)?;

    require!(
        amount_out >= minimum_out,
        AdvancedErrorCode::SlippageExceeded
    );

    Ok(())
}
```

### Error Recovery

```rust
pub fn safe_transfer(
    from: &AccountInfo,
    to: &AccountInfo,
    amount: u64
) -> Result<()> {
    match transfer(from, to, amount) {
        Ok(_) => Ok(()),
        Err(ProgramError::InsufficientFunds) => {
            msg!("Insufficient funds, retrying with smaller amount");
            transfer(from, to, amount / 2)
        }
        Err(e) => Err(e),
    }
}
```

## Event Logging

### Emitting Events

```rust
use anchor_lang::prelude::*;

#[event]
pub struct TransferEvent {
    pub from: Pubkey,
    pub to: Pubkey,
    pub amount: u64,
    pub timestamp: i64,
}

pub fn transfer_with_event(
    ctx: Context<Transfer>,
    amount: u64
) -> Result<()> {
    // Perform transfer
    transfer(ctx.accounts.from, ctx.accounts.to, amount)?;

    // Emit event
    emit!(TransferEvent {
        from: *ctx.accounts.from.key,
        to: *ctx.accounts.to.key,
        amount,
        timestamp: Clock::get()?.unix_timestamp,
    });

    Ok(())
}
```

### Listening to Events (Client-side)

```javascript
const connection = new Connection('https://api.devnet.solana.com');
const signature = await connection.sendTransaction(transaction);

// Wait for confirmation and parse logs
const confirmation = await connection.confirmTransaction(signature);

if (confirmation.value.err) {
  console.error('Transaction failed');
} else {
  // Parse events from logs
  const logs = confirmation.value.logMessages;
  const events = logs
    .filter(log => log.includes('Program data:'))
    .map(log => parseEvent(log));

  console.log('Events:', events);
}
```

## Oracle Integration

### Pyth Oracle

```rust
use pyth_sdk_solana::load_price_feed_account;

pub fn get_oracle_price(
    ctx: Context<GetPrice>
) -> Result<u64> {
    let price_feed = load_price_feed_account(
        &ctx.accounts.pyth_account.to_account_info()
    )?;

    let price = &price_feed.price;
    msg!("Price: {} ± {}", price.price, price.conf);

    Ok(price.price)
}
```

### Switchboard Oracle

```rust
use switchboard_solana::AggregatorAccountData;

pub fn get_switchboard_price(
    ctx: Context<GetSwitchboardPrice>
) -> Result<u64> {
    let aggregator = AggregatorAccountData::new(
        &ctx.accounts.aggregator.to_account_info()
    )?;

    let price = aggregator.get_result()?;

    Ok(price.try_into()?)
}
```

## Security Patterns

### Reentrancy Protection

```rust
#[account]
pub struct Vault {
    pub authority: Pubkey,
    pub locked: bool,
}

pub fn secure_withdraw(
    ctx: Context<Withdraw>,
    amount: u64
) -> Result<()> {
    let vault = &mut ctx.accounts.vault;

    // Check reentrancy lock
    require!(!vault.locked, ErrorCode::Locked);

    // Set lock
    vault.locked = true;

    // Perform withdrawal
    transfer(
        &ctx.accounts.vault.to_account_info(),
        &ctx.accounts.authority.to_account_info(),
        amount
    )?;

    // Release lock
    vault.locked = false;

    Ok(())
}
```

### Access Control

```rust
pub struct AccessControl;

impl AccessControl {
    pub fn only_owner(
        account: &AccountInfo,
        owner: &Pubkey
    ) -> Result<()> {
        require!(
            account.key == owner,
            ErrorCode::Unauthorized
        );
        Ok(())
    }

    pub fn only_admin(
        account: &AccountInfo,
        admin_config: &AdminConfig
    ) -> Result<()> {
        require!(
            admin_config.is_admin(account.key),
            ErrorCode::Unauthorized
        );
        Ok(())
    }
}
```

## Testing Patterns

### Integration Testing

```typescript
import * as anchor from '@coral-xyz/anchor';

describe('Advanced Tests', () => {
  it('Handles concurrent transactions', async () => {
    const tx1 = program.methods
      .concurrentUpdate()
      .accounts({ /* ... */ })
      .transaction();

    const tx2 = program.methods
      .concurrentUpdate()
      .accounts({ /* ... */ })
      .transaction();

    // Send both transactions
    await Promise.all([
      provider.sendAndConfirm(tx1),
      provider.sendAndConfirm(tx2),
    ]);
  });
});
```

### Fuzz Testing

```bash
# Using cargo-fuzz
cargo install cargo-fuzz

cargo fuzz init
cargo fuzz add fuzz_target_1

cargo fuzz run fuzz_target_1
```

## Performance Optimization

### Compute Budget Management

```rust
use solana_program::compute_budget::ComputeBudgetInstruction;

pub fn optimize_compute(
    ctx: Context<Optimize>
) -> Result<()> {
    // Request additional compute units
    let request_units_ix = ComputeBudgetInstruction::set_compute_unit_limit(
        400_000
    );

    let set_price_ix = ComputeBudgetInstruction::set_compute_unit_price(
        1000 // Micro-lamports per CU
    );

    invoke(&request_units_ix, ctx.accounts.as_ref())?;
    invoke(&set_price_ix, ctx.accounts.as_ref())?;

    // Main logic
    expensive_operation(ctx)?;

    Ok(())
}
```

### Batch Operations

```rust
pub fn batch_transfer(
    ctx: Context<BatchTransfer>,
    recipients: Vec<(Pubkey, u64)>
) -> Result<()> {
    for (recipient, amount) in recipients {
        transfer(
            &ctx.accounts.from.to_account_info(),
            &AccountInfo::new(&recipient, false, true, &[]),
            amount
        )?;
    }

    Ok(())
}
```

## DeFi Patterns

### AMM (Automated Market Maker)

```rust
pub fn swap_tokens(
    ctx: Context<Swap>,
    amount_in: u64
) -> Result<u64> {
    let pool = &mut ctx.accounts.pool;

    // Calculate output amount using constant product formula
    let amount_out = (pool.reserve_b * amount_in) / (pool.reserve_a + amount_in);

    // Update reserves
    pool.reserve_a += amount_in;
    pool.reserve_b -= amount_out;

    // Transfer tokens
    token::transfer(
        CpiContext::new(
            ctx.accounts.token_program.to_account_info(),
            token::Transfer {
                from: ctx.accounts.user_a.to_account_info(),
                to: ctx.accounts.pool_a.to_account_info(),
                authority: ctx.accounts.user.to_account_info(),
            },
        ),
        amount_in
    )?;

    token::transfer(
        CpiContext::new_with_signer(
            ctx.accounts.token_program.to_account_info(),
            token::Transfer {
                from: ctx.accounts.pool_b.to_account_info(),
                to: ctx.accounts.user_b.to_account_info(),
                authority: ctx.accounts.pool.to_account_info(),
            },
            &[&[b"pool", &[pool.bump]]],
        ),
        amount_out
    )?;

    Ok(amount_out)
}
```

## Best Practices

1. **Optimize compute usage** - Keep instructions efficient
2. **Use events for logging** - Easier debugging
3. **Implement proper access control** - Security first
4. **Test thoroughly** - Unit and integration tests
5. **Document complex logic** - Clear comments
6. **Handle edge cases** - Robust error handling
7. **Use security audits** - Professional review
8. **Monitor gas costs** - Optimize where possible

## Next Steps

- `/solana-programs` - Program development
- `/solana-deployment` - Deploying to mainnet
- `/solana-tokens` - Token operations

## Resources

- Advanced Patterns: https://solana.com/recipes
- Security Best Practices: https://solana.com/docs/security
- Program Library: https://github.com/solana-labs/solana-program-library
