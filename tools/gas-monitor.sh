#!/bin/bash
# Gas Price Monitor
# Track Ethereum gas prices and alert on spikes

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

show_help() {
    echo "Gas Price Monitor"
    echo ""
    echo "Usage: ./gas-monitor.sh [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  -t, --threshold GWEI    Alert threshold (default: 50)"
    echo "  -i, --interval SECONDS  Check interval (default: 60)"
    echo "  -o, --once              Run once and exit"
    echo "  -h, --help              Show this help"
    echo ""
    echo "Examples:"
    echo "  ./gas-monitor.sh                    # Monitor continuously"
    echo "  ./gas-monitor.sh -t 30 -o           # Check once, alert if >30 gwei"
    echo "  ./gas-monitor.sh -i 300             # Check every 5 minutes"
    echo ""
}

THRESHOLD=50
INTERVAL=60
ONCE=false

while [[ $# -gt 0 ]]; do
    case $1 in
        -t|--threshold)
            THRESHOLD="$2"
            shift 2
            ;;
        -i|--interval)
            INTERVAL="$2"
            shift 2
            ;;
        -o|--once)
            ONCE=true
            shift
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

echo -e "${BLUE}=== Gas Price Monitor ===${NC}"
echo ""
echo "Alert Threshold: ${THRESHOLD} gwei"
echo "Check Interval: ${INTERVAL} seconds"
if [ "$ONCE" = true ]; then
    echo "Mode: Single check"
else
    echo "Mode: Continuous monitoring"
fi
echo ""

# Function to get gas prices (simulated for template)
get_gas_prices() {
    # In production, this would query:
    # - eth_gasPrice via RPC
    # - Oracles like Chainlink
    # - API endpoints
    
    # Simulated data
    SAFE_LOW=25
    STANDARD=35
    FAST=50
    RAPID=75
    
    echo "$SAFE_LOW $STANDARD $FAST $RAPID"
}

# Function to display gas prices
display_prices() {
    local safe=$1
    local standard=$2
    local fast=$3
    local rapid=$4
    
    echo -e "${GREEN}Current Gas Prices:${NC}"
    echo "  Safe Low:  ${safe} gwei"
    echo "  Standard:  ${standard} gwei"
    echo "  Fast:      ${fast} gwei"
    echo "  Rapid:     ${rapid} gwei"
    echo ""
    
    # Calculate costs for common operations
    echo -e "${YELLOW}Estimated Costs:${NC}"
    
    # Simple transfer: 21,000 gas
    transfer_cost_safe=$(echo "scale=6; 21000 * $safe / 1000000000" | bc)
    transfer_cost_fast=$(echo "scale=6; 21000 * $fast / 1000000000" | bc)
    echo "  Simple Transfer: \$${transfer_cost_safe} - \$${transfer_cost_fast}"
    
    # Token transfer: ~65,000 gas
    token_cost_safe=$(echo "scale=6; 65000 * $safe / 1000000000" | bc)
    token_cost_fast=$(echo "scale=6; 65000 * $fast / 1000000000" | bc)
    echo "  Token Transfer:  \$${token_cost_safe} - \$${token_cost_fast}"
    
    # Uniswap swap: ~150,000 gas
    swap_cost_safe=$(echo "scale=6; 150000 * $safe / 1000000000" | bc)
    swap_cost_fast=$(echo "scale=6; 150000 * $fast / 1000000000" | bc)
    echo "  Uniswap Swap:    \$${swap_cost_safe} - \$${swap_cost_fast}"
    
    # Contract deployment: ~2,000,000 gas
    deploy_cost_safe=$(echo "scale=6; 2000000 * $safe / 1000000000" | bc)
    deploy_cost_fast=$(echo "scale=6; 2000000 * $fast / 1000000000" | bc)
    echo "  Deploy Contract: \$${deploy_cost_safe} - \$${deploy_cost_fast}"
    
    echo ""
}

# Function to check threshold
check_threshold() {
    local fast=$1
    
    if (( $(echo "$fast > $THRESHOLD" | bc -l) )); then
        echo -e "${RED}⚠️  ALERT: Gas price above threshold!${NC}"
        echo "Current: ${fast} gwei"
        echo "Threshold: ${THRESHOLD} gwei"
        echo ""
        echo "Recommendation: Wait for gas prices to decrease"
        echo "Typical low-gas times: UTC 02:00-08:00, Weekends"
        echo ""
        return 1
    fi
    
    return 0
}

# Main monitoring loop
monitor() {
    while true; do
        TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S UTC')
        echo "[$TIMESTAMP]"
        
        read safe standard fast rapid <<< $(get_gas_prices)
        
        display_prices $safe $standard $fast $rapid
        
        if check_threshold $fast; then
            echo -e "${GREEN}✓ Gas prices acceptable${NC}"
        fi
        
        if [ "$ONCE" = true ]; then
            break
        fi
        
        echo "Checking again in ${INTERVAL} seconds..."
        echo ""
        sleep $INTERVAL
    done
}

# Check if bc is available
if ! command -v bc &> /dev/null; then
    echo -e "${YELLOW}Warning: 'bc' not found. Some features limited.${NC}"
    echo "Install with: sudo apt-get install bc"
    echo ""
fi

# Start monitoring
monitor
