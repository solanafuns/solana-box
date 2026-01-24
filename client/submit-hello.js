import {
  Connection,
  PublicKey,
  Keypair,
  Transaction,
  TransactionInstruction,
  sendAndConfirmTransaction,
} from '@solana/web3.js';
import { BorshInstructionCoder } from '@coral-xyz/anchor';
import * as borsh from 'borsh';

// Define the HelloMessage structure matching the Solana program
class HelloMessage {
  constructor(properties) {
    this.message = properties.message;
    this.timestamp = properties.timestamp;
  }

  static schema = new Map([
    [HelloMessage, {
      kind: 'struct',
      fields: [
        ['message', 'string'],
        ['timestamp', 'i64'],
      ],
    }],
  ]);
}

/**
 * Submit a "Hello World" message with current timestamp to the Solana program
 */
async function submitHelloWorld() {
  // Configure connection (uses devnet by default)
  const RPC_URL = process.env.RPC_URL || 'https://api.devnet.solana.com';
  const connection = new Connection(RPC_URL, 'confirmed');

  console.log('🌐 Connecting to Solana devnet...');
  console.log('RPC URL:', RPC_URL);

  // Get the program ID from environment or use a placeholder
  // You'll need to deploy the program first and update this
  const PROGRAM_ID = new PublicKey(process.env.PROGRAM_ID || '11111111111111111111111111111111');

  // Load payer keypair from default Solana location or generate new one
  let payer;
  const DEFAULT_KEYPAIR_PATH = process.env.HOME + '/.config/solana/id.json';

  try {
    const fs = await import('fs');
    const keypairData = JSON.parse(fs.readFileSync(DEFAULT_KEYPAIR_PATH, 'utf8'));
    payer = Keypair.fromSecretKey(new Uint8Array(keypairData));
    console.log('✅ Loaded keypair from', DEFAULT_KEYPAIR_PATH);
  } catch (err) {
    console.log('⚠️  No default keypair found, generating new one...');
    payer = Keypair.generate();
    console.log('🔑 New public key:', payer.publicKey.toBase58());
    console.log('💾 Save this keypair or airdrop SOL to it for transactions');
  }

  // Check balance
  const balance = await connection.getBalance(payer.publicKey);
  console.log('💰 Current balance:', balance / 1e9, 'SOL');

  if (balance === 0) {
    console.log('⚠️  No SOL found. Please airdrop SOL to this address:');
    console.log('solana airdrop 2 ' + payer.publicKey.toBase58());
    return;
  }

  // Create a data account for storing the message
  const dataAccount = Keypair.generate();
  console.log('📝 Creating data account:', dataAccount.publicKey.toBase58());

  const createAccountTx = await connection.requestAirdrop(dataAccount.publicKey, 1e9);
  await connection.confirmTransaction(createAccountTx);

  // Create Hello World message with current timestamp
  const message = "Hello World!";
  const timestamp = Date.now(); // Current time in milliseconds

  console.log('📤 Submitting message:', message);
  console.log('⏰ Timestamp:', timestamp, `(${new Date(timestamp).toISOString()})`);

  const helloMessage = new HelloMessage({
    message,
    timestamp,
  });

  // Serialize the instruction data
  const instructionData = borsh.serialize(
    HelloMessage.schema,
    helloMessage
  );

  // Create the instruction
  const instruction = new TransactionInstruction({
    keys: [
      { pubkey: dataAccount.publicKey, isSigner: true, isWritable: true },
    ],
    programId: PROGRAM_ID,
    data: Buffer.from(instructionData),
  });

  // Create and send transaction
  const transaction = new Transaction().add(instruction);

  try {
    console.log('🚀 Sending transaction...');
    const signature = await sendAndConfirmTransaction(
      connection,
      transaction,
      [payer, dataAccount],
      { commitment: 'confirmed' }
    );

    console.log('✅ Transaction successful!');
    console.log('🔗 Signature:', signature);
    console.log('');
    console.log('📜 View on Solana Explorer:');
    console.log(`https://explorer.solana.com/tx/${signature}?cluster=devnet`);

    // Read back the data
    const accountInfo = await connection.getAccountInfo(dataAccount.publicKey);
    if (accountInfo && accountInfo.data.length > 0) {
      const decoded = borsh.deserialize(
        HelloMessage.schema,
        HelloMessage,
        accountInfo.data
      );
      console.log('');
      console.log('✨ Stored on-chain data:');
      console.log('   Message:', decoded.message);
      console.log('   Timestamp:', decoded.timestamp);
      console.log('   DateTime:', new Date(decoded.timestamp).toISOString());
    }

  } catch (error) {
    console.error('❌ Transaction failed:', error.message);
    if (error.message.includes('custom program error')) {
      console.log('💡 Make sure the program is deployed and PROGRAM_ID is set correctly');
    }
  }
}

// Run the function
submitHelloWorld().catch(console.error);
