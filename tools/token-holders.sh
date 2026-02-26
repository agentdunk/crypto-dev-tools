#!/bin/bash
# Token Holder Distribution Analyzer
# Analyze holder concentration and whale activity

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

show_help() {
    echo "Token Holder Distribution Analyzer"
    echo ""
    echo "Usage: ./token-holders.sh [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  -c, --contract ADDRESS    Token contract address (required)"
    echo "  -n, --network NETWORK     Network (ethereum, polygon, arbitrum)"
    echo "  -t, --top N              Show top N holders (default: 10)"
    echo "  -m, --min-balance AMOUNT  Minimum balance to display"
    echo "  -h, --help                Show this help"
    echo ""
    echo "Examples:"
    echo "  ./token-holders.sh -c 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48 -n ethereum"
    echo "  ./token-holders.sh -c 0x... -n polygon -t 20"
    echo ""
}

# Default values
NETWORK="ethereum"
TOP_HOLDERS=10
MIN_BALANCE=0
CONTRACT=""

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -c|--contract)
            CONTRACT="$2"
            shift 2
            ;;
        -n|--network)
            NETWORK="$2"
            shift 2
            ;;
        -t|--top)
            TOP_HOLDERS="$2"
            shift 2
            ;;
        -m|--min-balance)
            MIN_BALANCE="$2"
            shift 2
            ;;
        -h|--help)
            show_help
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            show_help
            exit 1
            ;;
    esac
done

if [ -z "$CONTRACT" ]; then
    echo -e "${RED}Error: Contract address required${NC}"
    show_help
    exit 1
fi

echo -e "${BLUE}=== Token Holder Distribution Analyzer ===${NC}"
echo ""
echo "Contract: $CONTRACT"
echo "Network: $NETWORK"
echo "Analysis Date: $(date)"
echo ""

# Note: This is a template. In production, you would:
# 1. Query blockchain data (via ethers.js, web3.py, or direct RPC)
# 2. Parse Transfer events
# 3. Calculate balances
# 4. Sort and display

echo -e "${YELLOW}Note: This tool requires blockchain data access.${NC}"
echo "To use with real data:"
echo "1. Set up API key for Etherscan/Alchemy"
echo "2. Query token contract for holder data"
echo "3. Parse results"
echo ""

# Simulate analysis output
echo -e "${GREEN}Sample Analysis Output:${NC}"
echo ""
echo "Total Holders: 15,234"
echo "Total Supply: 1,000,000,000 tokens"
echo ""
echo "Top 10 Holders:"
echo "Rank | Address | Balance | % Supply"
echo "-----|---------|---------|----------"
echo "1    | 0x7a2... | 250,000,000 | 25.0%"
echo "2    | 0x3b9... | 180,000,000 | 18.0%"
echo "3    | 0x8f4... | 95,000,000  | 9.5%"
echo "4    | 0x2c1... | 67,000,000  | 6.7%"
echo "5    | 0x9e5... | 45,000,000  | 4.5%"
echo ""

echo -e "${GREEN}Concentration Metrics:${NC}"
echo "Top 10 holders control: 63.7%"
echo "Top 50 holders control: 78.2%"
echo "Top 100 holders control: 85.4%"
echo "Gini Coefficient: 0.82 (High concentration)"
echo ""

echo -e "${YELLOW}Risk Assessment:${NC}"
echo "⚠️  High whale concentration detected"
echo "⚠️  Top 3 wallets control >50% of supply"
echo "⚠️  Monitor large transfers for price impact"
echo ""

echo -e "${GREEN}Recommendations:${NC}"
echo "• Diversify across multiple tokens"
echo "• Monitor whale wallet movements"
echo "• Check if top holders are contracts (multisig, treasury)"
echo "• Be cautious of low-liquidity exits"
echo ""
