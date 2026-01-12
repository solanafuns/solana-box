# Solana Programs (Smart Contracts)

This skill covers writing, building, and deploying Solana programs using Rust and the Anchor framework.

## Getting Started

### Prerequisites

- Rust toolchain installed
- Solana CLI installed
- Anchor framework installed (recommended)

### Creating a New Program

**With Anchor:**
```bash
anchor init my-program
cd my-program
```

**With Cargo:**
```bash
cargo new my-program --lib
cd my-program
```

Add to `Cargo.toml`:
```toml
[dependencies]
solana-program = "1.18"
```

## Basic Program Structure

### Minimal Program (Pure Rust)

```rust
use solana_program::{
    account_info::AccountInfo,
    entrypoint,
    entrypoint::ProgramResult,
    pubkey::Pubkey,
};

entrypoint!(process_instruction);

pub fn process_instruction(
    program_id: &Pubkey,
    accounts: &[AccountInfo],
    instruction_data: &[u8],
) -> ProgramResult {
    // Your program logic here
    msg!("Hello, Solana!");
    Ok(())
}
```

### With Anchor

```rust
use anchor_lang::prelude::*;

declare_id!("YOUR_PROGRAM_ID_HERE");

#[program]
pub mod my_program {
    use super::*;

    pub fn initialize(ctx: Context<Initialize>) -> Result<()> {
        msg!("Greetings from: {:?}", ctx.program_id);
        Ok(())
    }
}

#[derive(Accounts)]
pub struct Initialize {}
```

## Instruction Data

### Defining Instruction Data

```rust
use borsh::{BorshSerialize, BorshDeserialize};

#[derive(BorshSerialize, BorshDeserialize, Debug)]
pub struct InstructionData {
    pub amount: u64,
    pub option: u8,
}
```

### Parsing Instruction Data

```rust
pub fn process_instruction(
    program_id: &Pubkey,
    accounts: &[AccountInfo],
    instruction_data: &[u8],
) -> ProgramResult {
    let instruction = InstructionData::try_from_slice(instruction_data)?;

    msg!("Amount: {}", instruction.amount);
    msg!("Option: {}", instruction.option);

    Ok(())
}
```

## Account Validation

### Manual Account Validation

```rust
pub fn process_instruction(
    program_id: &Pubkey,
    accounts: &[AccountInfo],
    instruction_data: &[u8],
) -> ProgramResult {
    let accounts_iter = &mut accounts.iter();

    let payer = next_account_info(accounts_iter)?;
    let system_program = next_account_info(accounts_iter)?;

    // Validate payer
    assert!(payer.is_signer);
    assert!(payer.is_writable);

    // Validate system program
    assert!(system_program.key == &solana_program::system_program::id());

    Ok(())
}
```

### Anchor Account Validation

```rust
#[derive(Accounts)]
pub struct Transfer<'info> {
    #[account(mut)]
    pub from: Signer<'info>,

    #[account(mut)]
    pub to: AccountInfo<'info>,

    pub system_program: Program<'info, System>,
}
```

## State Management

### Creating State Account

```rust
use solana_program::{
    system_instruction,
    rent::Rent,
    system_program,
};

pub fn create_state_account(
    payer: &AccountInfo,
    state: &AccountInfo,
    system_program: &AccountInfo,
    size: usize,
) -> ProgramResult {
    let rent = Rent::get()?;
    let required_lamports = rent.minimum_balance(size);

    // Create account
    invoke(
        &system_instruction::create_account(
            payer.key,
            state.key,
            required_lamports,
            size as u64,
            &program_id,
        ),
        &[payer.clone(), state.clone(), system_program.clone()],
    )?;

    Ok(())
}
```

### Anchor State Account

```rust
#[account]
pub struct MyState {
    pub authority: Pubkey,
    pub counter: u64,
    pub data: Vec<u8>,
}

#[derive(Accounts)]
pub struct InitializeState<'info> {
    #[account(
        init,
        payer = payer,
        space = 8 + 32 + 8 + 4 // discriminator + authority + counter + vec prefix
    )]
    pub state: Account<'info, MyState>,

    #[account(mut)]
    pub payer: Signer<'info>,

    pub system_program: Program<'info, System>,
}

pub fn initialize_state(ctx: Context<InitializeState>) -> Result<()> {
    let state = &mut ctx.accounts.state;
    state.authority = ctx.accounts.payer.key();
    state.counter = 0;
    state.data = Vec::new();
    Ok(())
}
```

## Cross-Program Invocation (CPI)

### Basic CPI

```rust
use solana_program::program::invoke;

pub fn call_system_program(
    payer: &AccountInfo,
    recipient: &AccountInfo,
    system_program: &AccountInfo,
    amount: u64,
) -> ProgramResult {
    let instruction = system_instruction::transfer(
        payer.key,
        recipient.key,
        amount,
    );

    invoke(
        &instruction,
        &[
            payer.clone(),
            recipient.clone(),
            system_program.clone(),
        ],
    )?;

    Ok(())
}
```

### CPI with Signed Accounts

```rust
use solana_program::program::invoke_signed;

pub fn create_pda_account(
    payer: &AccountInfo,
    pda: &AccountInfo,
    system_program: &AccountInfo,
    seeds: &[&[u8]],
) -> ProgramResult {
    let (pda_key, bump) = Pubkey::find_program_address(seeds, &program_id);

    let instruction = system_instruction::create_account(
        payer.key,
        &pda_key,
        rent_lamports,
        space,
        &program_id,
    );

    invoke_signed(
        &instruction,
        &[payer.clone(), pda.clone(), system_program.clone()],
        &[&[seeds, &[bump.to_le()]], &[bump]],
    )?;

    Ok(())
}
```

### Anchor CPI

```rust
use anchor_lang::system_program;

pub fn transfer_sol(ctx: Context<Transfer>, amount: u64) -> Result<()> {
    let cpi_context = CpiContext::new(
        ctx.accounts.system_program.to_account_info(),
        system_program::Transfer {
            from: ctx.accounts.from.to_account_info(),
            to: ctx.accounts.to.to_account_info(),
        },
    );

    system_program::transfer(cpi_context, amount)?;
    Ok(())
}
```

## Error Handling

### Custom Errors

```rust
use solana_program::program_error::ProgramError;

#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum MyError {
    InvalidAmount,
    Unauthorized,
}

impl From<MyError> for ProgramError {
    fn from(e: MyError) -> Self {
        ProgramError::Custom(e as u32)
    }
}
```

### Anchor Errors

```rust
#[error_code]
pub enum MyErrorCode {
    #[msg("Invalid amount provided")]
    InvalidAmount,

    #[msg("Unauthorized access")]
    Unauthorized,

    #[msg("Account already initialized")]
    AlreadyInitialized,
}

pub fn validate_amount(amount: u64) -> Result<()> {
    require!(amount > 0, MyErrorCode::InvalidAmount);
    Ok(())
}
```

## Program Constraints

### Anchor Constraints

```rust
#[derive(Accounts)]
pub struct UpdateState<'info> {
    #[account(
        mut,
        has_one = authority,
        constraint = state.counter < 100 @ MyErrorCode::CounterTooHigh
    )]
    pub state: Account<'info, MyState>,

    pub authority: Signer<'info>,
}
```

### Common Constraints

| Constraint | Description |
|------------|-------------|
| `init` | Create new account |
| `mut` | Account is writable |
| `signer` | Account must sign |
| `has_one` | Field matches another account |
| `constraint` | Custom validation |
| `close` | Close account and return lamports |
| `seeds` | PDA derivation seeds |

## Instruction Variants

### Multiple Instructions

```rust
#[program]
pub mod my_program {
    use super::*;

    pub fn initialize(ctx: Context<Initialize>) -> Result<()> {
        // Initialize logic
        Ok(())
    }

    pub fn update(ctx: Context<Update>, value: u64) -> Result<()> {
        // Update logic
        Ok(())
    }

    pub fn close(ctx: Context<Close>) -> Result<()> {
        // Close logic
        Ok(())
    }
}
```

## Testing

### Unit Tests

```rust
#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_validation() {
        let result = validate_amount(100);
        assert!(result.is_ok());
    }
}
```

### Integration Tests (Anchor)

```rust
#[cfg(test)]
mod tests {
    use super::*;
    use anchor_lang::prelude::*;
    use anchor_client;

    #[test]
    fn test_initialize() {
        let program = Program::new(
            &program_id,
            &program_id,
        );

        let tx = program.request()
            .accounts(my_program::accounts::Initialize {})
            .args(my_program::instruction::Initialize {})
            .send();

        assert!(tx.is_ok());
    }
}
```

## Building and Deploying

### Build Program

**Anchor:**
```bash
anchor build
```

**Cargo:**
```bash
cargo build-bpf
# or
cargo build-sbf
```

### Get Program ID

**Anchor:**
```bash
anchor keys list
```

**Cargo:**
The program ID is in the compiled .so file

### Deploy Program

**Anchor:**
```bash
anchor deploy
```

**Solana CLI:**
```bash
solana program deploy ./target/deploy/my_program.so
```

## Program Upgradeability

### Upgrade Program

```bash
solana program upgrade PROGRAM_ID /path/to/new/program.so
```

### Set Upgrade Authority

```bash
solana program set-upgrade-authority PROGRAM_ID NEW_AUTHORITY
```

### Close Program

```bash
solana program close PROGRAM_ID RECIPIENT
```

## Best Practices

1. **Use Anchor** - Simplifies program development
2. **Validate all accounts** - Prevent exploits
3. **Use custom errors** - Better debugging
4. **Document instructions** - Clear API for users
5. **Write tests** - Ensure correctness
6. **Use PDAs** - Secure account derivation
7. **Check rent exemption** - Prevent account loss
8. **Implement proper access control** - Authority checks

## Security Considerations

1. **Always verify program ID** - Prevent spoofing
2. **Validate all inputs** - Prevent overflow/underflow
3. **Check signer status** - Ensure proper authorization
4. **Use safe math** - Prevent arithmetic errors
5. **Validate PDAs** - Ensure correct derivation
6. **Handle reentrancy** - Be careful with CPIs
7. **Audit code** - Review for vulnerabilities

## CLI Usage

### Build with Anchor

```bash
anchor build --verifiable
```

### Test with Anchor

```bash
anchor test
```

### Deploy Specific Program

```bash
anchor deploy --program-name my_program
```

## Next Steps

- `/solana-deployment` - Deployment strategies
- `/solana-advanced` - Advanced patterns
- `/solana-rpc-api` - Interacting with programs

## Resources

- Programs: https://solana.com/docs/programs
- Anchor Guide: https://www.anchor-lang.com/docs
- Example Programs: https://github.com/solana-labs/solana-program-library
