# Solana Frontend Development

This skill covers building frontend applications that interact with Solana, including wallet integration and transaction handling.

## Getting Started

### Web3.js Library

Install Solana Web3.js:

```bash
npm install @solana/web3.js
```

### Basic Setup

```javascript
const { Connection, PublicKey, Keypair } = require('@solana/web3.js');

// Create connection
const connection = new Connection('https://api.devnet.solana.com', 'confirmed');

// Generate keypair
const keypair = Keypair.generate();
console.log('Public key:', keypair.publicKey.toBase58());
```

## Wallet Integration

### Phantom Wallet

Phantom is the most popular Solana wallet.

**Install Phantom Provider:**

```bash
npm install @solana/wallet-adapter-wallets
```

**Connect to Phantom:**

```javascript
import { getPhantomWallet } from '@solana/wallet-adapter-wallets';

// Check if Phantom is installed
const getProvider = () => {
  if ('solana' in window) {
    const provider = window.solana;
    if (provider.isPhantom) {
      return provider;
    }
  }
  window.open('https://phantom.app/', '_blank');
};

const connectWallet = async () => {
  const provider = getProvider();
  try {
    const response = await provider.connect();
    console.log('Connected:', response.publicKey.toString());
    return response.publicKey;
  } catch (err) {
    console.error('Connection failed:', err);
  }
};
```

**Disconnect:**

```javascript
const disconnectWallet = async () => {
  const provider = getProvider();
  await provider.disconnect();
};
```

### Using Wallet Adapter

**Install dependencies:**

```bash
npm install @solana/wallet-adapter-base
npm install @solana/wallet-adapter-react
npm install @solana/wallet-adapter-react-ui
npm install @solana/wallet-adapter-wallets
npm install @solana/wallet-adapter-wallets-standard
```

**Setup React App:**

```jsx
import React, { useMemo } from 'react';
import { ConnectionProvider, WalletProvider } from '@solana/wallet-adapter-react';
import { WalletModalProvider } from '@solana/wallet-adapter-react-ui';
import { PhantomWalletAdapter } from '@solana/wallet-adapter-wallets';
import { WalletAdapterNetwork } from '@solana/wallet-adapter-base';

const App = () => {
  const network = WalletAdapterNetwork.Devnet;
  const endpoint = useMemo(() => 'https://api.devnet.solana.com', []);
  const wallets = useMemo(
    () => [new PhantomWalletAdapter()],
    []
  );

  return (
    <ConnectionProvider endpoint={endpoint}>
      <WalletProvider wallets={wallets} autoConnect>
        <WalletModalProvider>
          <YourComponent />
        </WalletModalProvider>
      </WalletProvider>
    </ConnectionProvider>
  );
};
```

**Use Wallet Hook:**

```jsx
import { useWallet } from '@solana/wallet-adapter-react';

const WalletComponent = () => {
  const { publicKey, connect, disconnect, connected } = useWallet();

  return (
    <div>
      {connected ? (
        <div>
          <p>Connected: {publicKey.toString()}</p>
          <button onClick={disconnect}>Disconnect</button>
        </div>
      ) : (
        <button onClick={connect}>Connect Wallet</button>
      )}
    </div>
  );
};
```

## Sending Transactions

### Transfer SOL

```javascript
import {
  Connection,
  PublicKey,
  Transaction,
  SystemProgram,
  LAMPORTS_PER_SOL
} from '@solana/web3.js';

const transferSol = async (fromWallet, toAddress, amount) => {
  const connection = new Connection('https://api.devnet.solana.com');
  const toPubkey = new PublicKey(toAddress);

  const transaction = new Transaction().add(
    SystemProgram.transfer({
      fromPubkey: fromWallet.publicKey,
      toPubkey: toPubkey,
      lamports: amount * LAMPORTS_PER_SOL
    })
  );

  const { blockhash } = await connection.getLatestBlockhash();
  transaction.recentBlockhash = blockhash;
  transaction.feePayer = fromWallet.publicKey;

  // Sign and send
  const signature = await fromWallet.signTransaction(transaction);
  const txid = await connection.sendRawTransaction(signature.serialize());

  await connection.confirmTransaction(txid);
  return txid;
};
```

### Using Provider to Sign

```javascript
const sendTransaction = async (provider, transaction) => {
  const { blockhash } = await connection.getLatestBlockhash();
  transaction.recentBlockhash = blockhash;
  transaction.feePayer = provider.publicKey;

  const { signature } = await provider.signAndSendTransaction(transaction);
  await connection.confirmTransaction(signature);
  return signature;
};
```

## Token Operations

### Get Token Balance

```javascript
import { getOrCreateAssociatedTokenAccount } from '@solana/spl-token';

const getTokenBalance = async (walletAddress, mintAddress) => {
  const connection = new Connection('https://api.devnet.solana.com');
  const mintPubkey = new PublicKey(mintAddress);

  try {
    const tokenAccount = await getOrCreateAssociatedTokenAccount(
      connection,
      wallet, // Signer
      mintPubkey,
      walletAddress,
      false
    );

    const balance = await connection.getTokenAccountBalance(
      tokenAccount.address
    );

    return balance.value.uiAmount;
  } catch (error) {
    console.error('Error getting balance:', error);
  }
};
```

### Transfer Tokens

```javascript
import { createTransferInstruction } from '@solana/spl-token';

const transferTokens = async (
  provider,
  mint,
  source,
  destination,
  amount
) => {
  const connection = new Connection('https://api.devnet.solana.com');

  const transaction = new Transaction().add(
    createTransferInstruction(
      source,
      destination,
      provider.publicKey,
      amount,
      [],
      TOKEN_PROGRAM_ID
    )
  );

  return await sendTransaction(provider, transaction);
};
```

## Real-time Updates

### Account Changes

```javascript
const subscribeToAccount = (connection, publicKey) => {
  const subscriptionId = connection.onAccountChange(
    publicKey,
    (accountInfo) => {
      console.log('Account updated:', accountInfo);
    },
    'confirmed'
  );

  return subscriptionId;
};

// Unsubscribe
connection.removeAccountChangeListener(subscriptionId);
```

### Transaction Logs

```javascript
const subscribeToLogs = (connection, programId) => {
  const subscriptionId = connection.onLogs(
    programId,
    (logs) => {
      console.log('Program logs:', logs);
    },
    'confirmed'
  );

  return subscriptionId;
};
```

### Signature Confirmation

```javascript
const confirmTransaction = async (connection, signature) => {
  const subscriptionId = connection.onSignature(
    signature,
    (result) => {
      console.log('Transaction result:', result);
    },
    'confirmed'
  );

  await connection.confirmTransaction(signature, 'confirmed');
  connection.removeSignatureChangeListener(subscriptionId);
};
```

## React Integration

### Custom Hook for Balance

```javascript
import { useState, useEffect } from 'react';
import { useConnection, useWallet } from '@solana/wallet-adapter-react';

const useBalance = () => {
  const { connection } = useConnection();
  const { publicKey } = useWallet();
  const [balance, setBalance] = useState(0);

  useEffect(() => {
    if (publicKey) {
      connection.getBalance(publicKey).then(setBalance);
    }
  }, [publicKey, connection]);

  return balance;
};

// Usage
const BalanceDisplay = () => {
  const balance = useBalance();
  return <div>Balance: {balance / LAMPORTS_PER_SOL} SOL</div>;
};
```

### Transaction Modal

```javascript
const TransactionModal = ({ transaction, onConfirm, onCancel }) => {
  const { signTransaction, connection } = useWallet();

  const handleConfirm = async () => {
    try {
      const signature = await signTransaction(transaction);
      await connection.confirmTransaction(signature);
      onConfirm(signature);
    } catch (error) {
      console.error('Transaction failed:', error);
    }
  };

  return (
    <div className="modal">
      <h3>Confirm Transaction</h3>
      <button onClick={handleConfirm}>Confirm</button>
      <button onClick={onCancel}>Cancel</button>
    </div>
  );
};
```

## Error Handling

### Common Errors

```javascript
const handleError = (error) => {
  if (error.message.includes('User rejected')) {
    console.log('User rejected the request');
  } else if (error.message.includes('insufficient funds')) {
    console.log('Insufficient funds for transaction');
  } else if (error.message.includes('blockhash expired')) {
    console.log('Transaction expired, please try again');
  } else {
    console.error('Unknown error:', error);
  }
};
```

### Transaction Error Parsing

```javascript
const parseTransactionError = async (connection, signature) => {
  const tx = await connection.getTransaction(signature);

  if (tx && tx.meta && tx.meta.err) {
    console.error('Transaction error:', tx.meta.err);
    return tx.meta.err;
  }
  return null;
};
```

## UI Components

### Wallet Button

```jsx
import { WalletMultiButton } from '@solana/wallet-adapter-react-ui';

const Header = () => {
  return (
    <header>
      <WalletMultiButton />
    </header>
  );
};
```

### Address Display

```javascript
const shortenAddress = (address) => {
  return `${address.slice(0, 4)}...${address.slice(-4)}`;
};

const AddressDisplay = ({ publicKey }) => {
  return (
    <span title={publicKey.toString()}>
      {shortenAddress(publicKey.toString())}
    </span>
  );
};
```

### Loading States

```jsx
const TransactionButton = ({ onClick, loading, children }) => {
  return (
    <button onClick={onClick} disabled={loading}>
      {loading ? 'Processing...' : children}
    </button>
  );
};
```

## Framework Integration

### Next.js

```javascript
// pages/_app.js
import { WalletAdapterNetwork } from '@solana/wallet-adapter-base';
import { ConnectionProvider, WalletProvider } from '@solana/wallet-adapter-react';
import { WalletModalProvider } from '@solana/wallet-adapter-react-ui';
import { PhantomWalletAdapter } from '@solana/wallet-adapter-wallets';
import { useMemo } from 'react';

function MyApp({ Component, pageProps }) {
  const network = WalletAdapterNetwork.Devnet;
  const endpoint = useMemo(() => 'https://api.devnet.solana.com', []);
  const wallets = useMemo(() => [new PhantomWalletAdapter()], []);

  return (
    <ConnectionProvider endpoint={endpoint}>
      <WalletProvider wallets={wallets} autoConnect>
        <WalletModalProvider>
          <Component {...pageProps} />
        </WalletModalProvider>
      </WalletProvider>
    </ConnectionProvider>
  );
}

export default MyApp;
```

### Vue.js

```javascript
import { initWalletAdapter } from '@solana/wallet-adapter-vue';

const app = createApp(App);
app.use(initWalletAdapter());
```

## Best Practices

1. **Handle connection state** - Show loading/disconnected states
2. **Validate user input** - Check addresses and amounts
3. **Show transaction progress** - Confirmations, errors
4. **Use TypeScript** - Type safety for addresses and transactions
5. **Test on devnet** - Before mainnet deployment
6. **Handle errors gracefully** - User-friendly error messages
7. **Cache RPC responses** - Reduce API calls
8. **Use subscriptions** - For real-time updates
9. **Implement reconnection logic** - Handle network issues
10. **Secure private keys** - Never expose them

## Next Steps

- `/solana-transactions` - Building transactions
- `/solana-rpc-api` - RPC methods
- `/solana-tokens` - Token operations

## Resources

- Wallet Adapter: https://solanacookbook.com/references/wallets.html
- Web3.js Docs: https://solana-labs.github.io/solana-web3.js/
- Frontend Guide: https://solana.com/docs/guides/frontend
