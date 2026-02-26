#!/bin/bash
# DeFi Yield Calculator
# Calculate yields across different protocols and strategies

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Default values
PRINCIPAL=1000
APY=5.0
DAYS=365
COMPOUND_FREQUENCY=1

# Help function
show_help() {
    echo "DeFi Yield Calculator"
    echo ""
    echo "Usage: ./yield-calc.sh [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  -p, --principal AMOUNT     Principal amount (default: 1000)"
    echo "  -a, --apy PERCENTAGE       APY percentage (default: 5.0)"
    echo "  -d, --days DAYS            Investment period in days (default: 365)"
    echo "  -c, --compound FREQ        Compound frequency per year (default: 1)"
    echo "  -s, --strategy             Show common DeFi strategies"
    echo "  -h, --help                 Show this help message"
    echo ""
    echo "Examples:"
    echo "  ./yield-calc.sh -p 10000 -a 8.5 -d 180"
    echo "  ./yield-calc.sh --strategy"
    echo ""
}

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -p|--principal)
            PRINCIPAL="$2"
            shift 2
            ;;
        -a|--apy)
            APY="$2"
            shift 2
            ;;
        -d|--days)
            DAYS="$2"
            shift 2
            ;;
        -c|--compound)
            COMPOUND_FREQUENCY="$2"
            shift 2
            ;;
        -s|--strategy)
            show_strategies
            exit 0
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

# Show DeFi strategies
show_strategies() {
    echo -e "${BLUE}=== Common DeFi Yield Strategies ===${NC}"
    echo ""
    
    echo -e "${GREEN}1. Simple Lending (Aave/Compound)${NC}"
    echo "   APY: 3-8%"
    echo "   Risk: Very Low"
    echo "   Effort: Minimal"
    echo "   Best for: Beginners, stablecoin holders"
    echo ""
    
    echo -e "${GREEN}2. Liquidity Provision (Uniswap/Curve)${NC}"
    echo "   APY: 10-50%"
    echo "   Risk: Medium (impermanent loss)"
    echo "   Effort: Medium"
    echo "   Best for: Active traders, crypto natives"
    echo ""
    
    echo -e "${GREEN}3. Yield Farming (Convex, Yearn)${NC}"
    echo "   APY: 15-100%+"
    echo "   Risk: Medium-High"
    echo "   Effort: High"
    echo "   Best for: Advanced users, higher risk tolerance"
    echo ""
    
    echo -e "${GREEN}4. Staking (ETH, SOL, etc.)${NC}"
    echo "   APY: 4-20%"
    echo "   Risk: Low-Medium"
    echo "   Effort: Minimal"
    echo "   Best for: Long-term holders"
    echo ""
    
    echo -e "${GREEN}5. Recursive Lending (Looping)${NC}"
    echo "   APY: 10-30%"
    echo "   Risk: High (liquidation risk)"
    echo "   Effort: High"
    echo "   Best for: Advanced users, bull markets"
    echo ""
}

# Calculate compound interest
calculate_compound() {
    local p=$1
    local r=$2
    local t=$3
    local n=$4
    
    # Convert percentage to decimal
    local rate=$(echo "scale=10; $r / 100" | bc)
    
    # Calculate: A = P(1 + r/n)^(nt)
    local base=$(echo "scale=10; 1 + ($rate / $n)" | bc)
    local exponent=$(echo "scale=10; $n * $t" | bc)
    
    # Use awk for power calculation
    local result=$(awk "BEGIN {print $p * ($base ^ $exponent)}")
    echo $result
}

# Simple interest
calculate_simple() {
    local p=$1
    local r=$2
    local t=$3
    
    # I = P * r * t
    local rate=$(echo "scale=10; $r / 100" | bc)
    local interest=$(echo "scale=2; $p * $rate * $t" | bc)
    local total=$(echo "scale=2; $p + $interest" | bc)
    
    echo "$total"
}

# Main calculation
main() {
    echo -e "${BLUE}=== DeFi Yield Calculator ===${NC}"
    echo ""
    
    # Input summary
    echo -e "${YELLOW}Input Parameters:${NC}"
    echo "  Principal: \$${PRINCIPAL}"
    echo "  APY: ${APY}%"
    echo "  Duration: ${DAYS} days"
    echo "  Compound Frequency: ${COMPOUND_FREQUENCY}x per year"
    echo ""
    
    # Calculate time in years
    YEARS=$(echo "scale=4; $DAYS / 365" | bc)
    
    # Simple interest calculation
    SIMPLE_RATE=$(echo "scale=10; $APY / 100" | bc)
    SIMPLE_INTEREST=$(echo "scale=2; $PRINCIPAL * $SIMPLE_RATE * $YEARS" | bc)
    SIMPLE_TOTAL=$(echo "scale=2; $PRINCIPAL + $SIMPLE_INTEREST" | bc)
    
    echo -e "${GREEN}Simple Interest (No Compounding):${NC}"
    echo "  Interest Earned: \$${SIMPLE_INTEREST}"
    echo "  Total Value: \$${SIMPLE_TOTAL}"
    echo ""
    
    # Compound interest (if bc is available)
    if command -v bc &> /dev/null; then
        COMPOUND_TOTAL=$(calculate_compound $PRINCIPAL $APY $YEARS $COMPOUND_FREQUENCY)
        COMPOUND_INTEREST=$(echo "scale=2; $COMPOUND_TOTAL - $PRINCIPAL" | bc)
        
        echo -e "${GREEN}Compound Interest (${COMPOUND_FREQUENCY}x/year):${NC}"
        echo "  Interest Earned: \$${COMPOUND_INTEREST}"
        echo "  Total Value: \$${COMPOUND_TOTAL}"
        echo ""
        
        # Difference
        DIFF=$(echo "scale=2; $COMPOUND_INTEREST - $SIMPLE_INTEREST" | bc)
        echo -e "${YELLOW}Compounding Benefit: +\$${DIFF}${NC}"
        echo ""
    fi
    
    # Daily breakdown
    DAILY_RATE=$(echo "scale=6; $APY / 36500" | bc)
    DAILY_EARN=$(echo "scale=4; $PRINCIPAL * $DAILY_RATE" | bc)
    
    echo -e "${BLUE}Daily Breakdown:${NC}"
    echo "  Daily Rate: ${DAILY_RATE}%"
    echo "  Daily Earnings: \$${DAILY_EARN}"
    echo ""
    
    # Monthly breakdown
    MONTHLY_EARN=$(echo "scale=2; $DAILY_EARN * 30" | bc)
    echo "  Monthly Earnings: ~\$${MONTHLY_EARN}"
    echo ""
    
    # Risk warning
    echo -e "${RED}⚠️  Risk Warning:${NC}"
    echo "  - APYs are not guaranteed and can change"
    echo "  - Smart contract risk exists in all DeFi protocols"
    echo "  - Impermanent loss may reduce returns in LP positions"
    echo "  - Do your own research (DYOR) before investing"
    echo ""
}

# Check if bc is available
if ! command -v bc &> /dev/null; then
    echo -e "${YELLOW}Warning: 'bc' calculator not found. Installing...${NC}"
    echo "  Run: sudo apt-get install bc"
    echo ""
fi

# Run main calculation
main
