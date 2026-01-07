#!/bin/bash

# Deploy script for Solana native example contract
# This script compiles and deploys the example contract to devnet
# using the default Solana account configured in the environment

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
CLUSTER="devnet"
PROGRAM_PATH="./example"
PROGRAM_NAME="example"
AIRDROP_AMOUNT="2"

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}  Solana Example Contract Deployer${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# Check if Solana CLI is installed
echo -e "${YELLOW}🔍 Checking Solana CLI installation...${NC}"
if ! command -v solana &> /dev/null; then
    echo -e "${RED}❌ Solana CLI is not installed!${NC}"
    echo "Please install Solana CLI first:"
    echo "  sh -c \"\$(curl -sSfL https://release.solana.com/stable/install)\""
    exit 1
fi

SOLANA_VERSION=$(solana --version)
echo -e "${GREEN}✅ Found: $SOLANA_VERSION${NC}"
echo ""

# Configure Solana CLI to use devnet
echo -e "${YELLOW}⚙️  Configuring Solana CLI for ${CLUSTER}...${NC}"
solana config set --url $CLUSTER
echo ""

# Show current configuration
echo -e "${BLUE}📋 Current Configuration:${NC}"
solana config get
echo ""

# Check default wallet
echo -e "${YELLOW}🔍 Checking default wallet...${NC}"
WALLET_ADDRESS=$(solana address)
echo -e "${GREEN}💰 Wallet address: $WALLET_ADDRESS${NC}"
echo ""

# Check balance
echo -e "${YELLOW}💵 Checking wallet balance...${NC}"
BALANCE=$(solana balance)
echo "Balance: $BALANCE"
echo ""

# Request airdrop if needed (only for devnet/testnet)
if [ "$CLUSTER" != "mainnet-beta" ]; then
    echo -e "${YELLOW}💸 Requesting airdrop of ${AIRDROP_AMOUNT} SOL...${NC}"
    solana airdrop $AIRDROP_AMOUNT || echo -e "${YELLOW}⚠️  Airdrop failed (might have enough funds)${NC}"
    echo ""
fi

# Navigate to program directory
echo -e "${YELLOW}📁 Navigating to program directory: ${PROGRAM_PATH}${NC}"
cd "$PROGRAM_PATH"
echo ""

# Build the program
echo -e "${YELLOW}🔨 Building Solana program...${NC}"
echo "Running: cargo build-sbf"
cargo build-sbf
echo ""

# Check if build was successful
PROGRAM_SO="target/deploy/${PROGRAM_NAME}.so"
if [ ! -f "$PROGRAM_SO" ]; then
    echo -e "${RED}❌ Build failed! Program file not found: $PROGRAM_SO${NC}"
    exit 1
fi
echo -e "${GREEN}✅ Build successful!${NC}"
echo ""

# Check for program keypair
PROGRAM_KEYPAIR="target/deploy/${PROGRAM_NAME}-keypair.json"
if [ -f "$PROGRAM_KEYPAIR" ]; then
    echo -e "${GREEN}✅ Found existing program keypair${NC}"
    PROGRAM_ID=$(solana address -k "$PROGRAM_KEYPAIR")
    echo -e "${BLUE}🆔 Program ID: $PROGRAM_ID${NC}"
else
    echo -e "${YELLOW}🔑 Generating new program keypair...${NC}"
    solana-keygen new --outfile "$PROGRAM_KEYPAIR" --no-bip39-passphrase --force
    PROGRAM_ID=$(solana address -k "$PROGRAM_KEYPAIR")
    echo -e "${GREEN}✅ Generated program keypair${NC}"
    echo -e "${BLUE}🆔 Program ID: $PROGRAM_ID${NC}"
fi
echo ""

# Deploy the program
echo -e "${YELLOW}🚀 Deploying program to ${CLUSTER}...${NC}"
solana program deploy "$PROGRAM_SO"
echo ""

# Success message
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}  ✅ Deployment Successful!${NC}"
echo -e "${GREEN}========================================${NC}"
echo -e "${BLUE}Program Name:${NC} ${PROGRAM_NAME}"
echo -e "${BLUE}Program ID:${NC}   ${PROGRAM_ID}"
echo -e "${BLUE}Cluster:${NC}      ${CLUSTER}"
echo -e "${BLUE}Program Path:${NC} ${PROGRAM_SO}"
echo ""
echo -e "${YELLOW}💡 Tip: Save your program keypair file!${NC}"
echo -e "   Location: ${PROGRAM_PATH}/${PROGRAM_KEYPAIR}"
echo ""
