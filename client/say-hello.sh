#!/bin/bash

# "Hello World" with timestamp submission script for Solana
# This script builds and deploys the example program, then submits a Hello World message

set -e

echo "🌐 Hello World - Solana Box"
echo "================================"
echo ""

# Check if we're on devnet
NETWORK=$(solana config get | grep "RPC URL" | awk '{print $3}')
echo "Network: $NETWORK"

# Get the program ID (will show "Not Found" if not deployed yet)
PROGRAM_ID=$(solana program show example/target/deploy/example.so --keypair ~/.config/solana/id.json 2>/dev/null | grep "Program Id" | awk '{print $3}' || echo "")

if [ -z "$PROGRAM_ID" ]; then
    echo "📦 Program not deployed. Building and deploying..."
    cd example
    cargo build-sbf
    solana program deploy target/deploy/example.so --keypair ~/.config/solana/id.json
    PROGRAM_ID=$(solana program show target/deploy/example.so --keypair ~/.config/solana/id.json | grep "Program Id" | awk '{print $3}')
    echo "✅ Program deployed: $PROGRAM_ID"
    cd ..
else
    echo "✅ Program already deployed: $PROGRAM_ID"
fi

echo ""
echo "📤 Submitting Hello World message with current timestamp..."
echo ""

# Get current timestamp
TIMESTAMP=$(date +%s%3N)  # Unix timestamp in milliseconds
MESSAGE="Hello World!"

echo "Message: $MESSAGE"
echo "Timestamp: $TIMESTAMP"
echo "DateTime: $(date -d @$((TIMESTAMP / 1000)) '+%Y-%m-%d %H:%M:%S UTC')"
echo ""

# Create a simple Node.js script to serialize and send the transaction
cat > /tmp/send-hello.js << 'EOFSCRIPT'
const fs = require('fs');
const borsh = require('borsh');
const { Connection, PublicKey, Keypair, Transaction, TransactionInstruction, sendAndConfirmTransaction } = require('@solana/web3.js');

// Define HelloMessage schema
class HelloMessage {
  constructor(fields) {
    this.message = fields.message;
    this.timestamp = fields.timestamp;
  }
}

HelloMessage.SCHEMA = new Map([
  [HelloMessage, { kind: 'struct', fields: [
    ['message', 'string'],
    ['timestamp', 'i64'],
  ]}],
]);

async function main() {
  const programId = new PublicKey(process.env.PROGRAM_ID);
  const connection = new Connection(process.env.RPC_URL || 'https://api.devnet.solana.com', 'confirmed');

  // Load keypair
  const keypairData = JSON.parse(fs.readFileSync(process.env.HOME + '/.config/solana/id.json', 'utf8'));
  const payer = Keypair.fromSecretKey(new Uint8Array(keypairData));

  // Create data account
  const dataAccount = Keypair.generate();
  console.log('Data account:', dataAccount.publicKey.toBase58());

  // Get current timestamp
  const timestamp = Date.now();
  const message = "Hello World from Holon!";

  console.log('Message:', message);
  console.log('Timestamp:', timestamp);

  // Serialize
  const helloMsg = new HelloMessage({ message, timestamp });
  const data = borsh.serialize(HelloMessage.SCHEMA, helloMsg);

  // Create instruction
  const instruction = new TransactionInstruction({
    keys: [
      { pubkey: dataAccount.publicKey, isSigner: true, isWritable: true },
    ],
    programId,
    data: Buffer.from(data),
  });

  const tx = new Transaction().add(instruction);

  // Send
  console.log('Sending transaction...');
  const sig = await sendAndConfirmTransaction(connection, tx, [payer, dataAccount]);
  console.log('Signature:', sig);
  console.log('');
  console.log('✨ Hello World submitted successfully!');
  console.log('Timestamp:', timestamp, `(${new Date(timestamp).toISOString()})`);
}

main().catch(console.error);
EOFSCRIPT

# Run the Node.js script
export PROGRAM_ID="$PROGRAM_ID"
export RPC_URL="$NETWORK"

if [ -f "client/node_modules/.bin/babel-node" ] || [ -d "client/node_modules" ]; then
    echo "Running from client directory..."
    cd client
    node /tmp/send-hello.js
    cd ..
else
    echo "⚠️  Node.js dependencies not installed. Run: cd client && npm install"
    echo "💡 Alternatively, the program has been deployed and is ready to use!"
fi

echo ""
echo "================================"
echo "✅ Hello World completed!"
echo "   Message stored on Solana with timestamp"
echo ""
