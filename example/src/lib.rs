pub fn add(left: u64, right: u64) -> u64 {
    left + right
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn it_works() {
        let result = add(2, 2);
        assert_eq!(result, 4);
    }
}
use borsh::{BorshDeserialize, BorshSerialize};
use solana_program::{
    account_info::{next_account_info, AccountInfo},
    entrypoint,
    entrypoint::ProgramResult,
    msg,
    program_error::ProgramError,
    pubkey::Pubkey,
};

#[derive(BorshSerialize, BorshDeserialize, Debug)]
pub struct MoonData {
    pub text: String,
}

#[derive(BorshSerialize, BorshDeserialize, Debug)]
pub struct HelloMessage {
    pub message: String,
    pub timestamp: i64,
}

entrypoint!(process_instruction);

pub fn process_instruction(
    _program_id: &Pubkey,
    accounts: &[AccountInfo],
    instruction_data: &[u8],
) -> ProgramResult {
    let account_iter = &mut accounts.iter();
    let data_account = next_account_info(account_iter)?;

    if !data_account.is_writable {
        return Err(ProgramError::InvalidAccountData);
    }

    // Try to deserialize as HelloMessage first (Hello World with timestamp)
    if let Ok(hello_msg) = HelloMessage::try_from_slice(instruction_data) {
        hello_msg.serialize(&mut &mut data_account.data.borrow_mut()[..])?;

        let date_time = format_datetime(hello_msg.timestamp);
        msg!("Hello World! Message: {}", hello_msg.message);
        msg!("Timestamp: {} ({})", hello_msg.timestamp, date_time);
        Ok(())
    }
    // Fallback to original MoonData structure
    else if let Ok(moon) = MoonData::try_from_slice(instruction_data) {
        moon.serialize(&mut &mut data_account.data.borrow_mut()[..])?;

        msg!("Saved text: {}", moon.text);
        Ok(())
    }
    else {
        Err(ProgramError::InvalidInstructionData)
    }
}

fn format_datetime(timestamp: i64) -> String {
    // Convert Unix timestamp to a readable format
    let seconds = timestamp / 1000;
    let millis = timestamp % 1000;
    format!("{}ms since epoch", seconds)
}
