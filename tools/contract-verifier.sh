#!/bin/bash
# Contract Verifier - Check if smart contracts are verified on Etherscan
# Essential for DeFi researchers, auditors, and security-conscious users

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
BOLD='\033[1m'
DIM='\033[2m'
NC='\033[0m' # No Color

# Configuration
ETHERSCAN_API_KEY="${ETHERSCAN_API_KEY:-}"
NETWORK="${NETWORK:-mainnet}"
OUTPUT_FORMAT="${OUTPUT_FORMAT:-pretty}"  # pretty, json, csv

# Supported networks
NETWORKS=(
    "mainnet:1:https://api.etherscan.io"
    "sepolia:11155111:https://api-sepolia.etherscan.io"
    "goerli:5:https://api-goerli.etherscan.io"
    "bsc:56:https://api.bscscan.com"
    "bsctest:97:https://api-testnet.bscscan.com"
    "polygon:137:https://api.polygonscan.com"
    "mumbai:80001:https://api-mumbai.polygonscan.com"
    "arbitrum:42161:https://api.arbiscan.io"
    "arbitrum-goerli:421613:https://api-goerli.arbiscan.io"
    "optimism:10:https://api-optimistic.etherscan.io"
    "base:8453:https://api.basescan.org"
    "fantom:250:https://api.ftmscan.com"
    "avalanche:43114:https://api.snowtrace.io"
)

# Help function
show_help() {
    cat << EOF
${BOLD}${CYAN}=== Smart Contract Verifier ===${NC}

Check if smart contracts are verified on Etherscan and get verification details.
Essential for security audits, DeFi research, and due diligence.

${YELLOW}Usage:${NC} ./contract-verifier.sh [OPTIONS] <address1> [address2] ...

${GREEN}Options:${NC}
  -k, --key API_KEY        Etherscan API key (required, or set ETHERSCAN_API_KEY)
  -n, --network NAME       Network (default: mainnet)
  -f, --format TYPE        Output format: pretty, json, csv (default: pretty)
  -b, --batch FILE         Read addresses from file (one per line)
  -a, --analyze           Deep analysis mode (checks implementation for proxies)
  -c, --compare ADDR1 ADDR2 Compare two contracts
  --networks               List supported networks
  -j, --json              Same as --format json
  -h, --help              Show this help message

${GREEN}Supported Networks:${NC}
  mainnet, sepolia, goerli, bsc, bsctest
  polygon, mumbai, arbitrum, arbitrum-goerli
  optimism, base, fantom, avalanche

${GREEN}Examples:${NC}
  # Check single contract
  ./contract-verifier.sh 0xdAC17F958D2ee523a2206206994597C13D831ec7

  # Check on Polygon
  ./contract-verifier.sh -n polygon 0x2791Bca1f2de4661ed88A30C99A7a9449Aa84174

  # Batch check from file
  ./contract-verifier.sh -k YOUR_KEY -b addresses.txt

  # Deep analysis (detects proxies, implementations)
  ./contract-verifier.sh -a 0x7d2768dE32b0b80b7a3454c06BdAc94A69DDc7A9

  # Compare two contracts
  ./contract-verifier.sh -c 0xABC... 0xDEF...

  # JSON output for scripting
  ./contract-verifier.sh --json 0xdAC17F958D2ee523a2206206994597C13D831ec7

${YELLOW}Environment Variables:${NC}
  ETHERSCAN_API_KEY        Your Etherscan API key (required)
  NETWORK                  Default network

${CYAN}Notes:${NC}
  - Unverified contracts are shown in ${RED}red${NC}
  - Verified contracts show compiler version and optimization
  - Proxy contracts are automatically detected
  - Rate limit: 5 calls/sec (handled automatically)

EOF
}

# Get API URL for network
get_api_url() {
    local net="$1"
    for n in "${NETWORKS[@]}"; do
        IFS=':' read -r name chainId url <<< "$n"
        if [[ "$name" == "$net" ]]; then
            echo "$url"
            return
        fi
    done
    echo "https://api.etherscan.io"  # Default to mainnet
}

# List supported networks
list_networks() {
    echo -e "${BOLD}${CYAN}=== Supported Networks ===${NC}\n"
    printf "${BOLD}%-20s %10s %s${NC}\n" "Network" "Chain ID" "API URL"
    echo "────────────────────────────────────────────────────────────"
    for n in "${NETWORKS[@]}"; do
        IFS=':' read -r name chainId url <<< "$n"
        printf "%-20s %10s %s\n" "$name" "$chainId" "$url"
    done
}

# Validate address
validate_address() {
    local addr="$1"
    if [[ ! "$addr" =~ ^0x[0-9a-fA-F]{40}$ ]]; then
        return 1
    fi
    return 0
}

# Normalize address (lowercase)
normalize_address() {
    echo "$1" | tr '[:upper:]' '[:lower:]'
}

# API rate limiting
last_call_time=0
rate_limit() {
    local now=$(date +%s%3N)
    local elapsed=$((now - last_call_time))
    if [[ $elapsed -lt 200 ]]; then  # 200ms = 5 req/sec max
        sleep $(echo "scale=3; (200 - $elapsed) / 1000" | bc)
    fi
    last_call_time=$(date +%s%3N)
}

# Check contract verification status
check_contract() {
    local address="$1"
    local api_base="$2"
    local api_key="$3"
    
    if ! validate_address "$address"; then
        echo "{\"error\":\"Invalid address format\",\"address\":\"$address\"}"
        return
    fi
    
    rate_limit
    
    # Get contract ABI (will fail if not verified)
    local response=$(curl -s "${api_base}/api?module=contract&action=getabi&address=${address}&apikey=${api_key}")
    local status=$(echo "$response" | jq -r '.status // "0"')
    local message=$(echo "$response" | jq -r '.message // "NOTOK"')
    
    if [[ "$status" != "1" || "$message" == "NOTOK" ]]; then
        # Not verified
        local balance=$(curl -s "${api_base}/api?module=account&action=balance&address=${address}&tag=latest&apikey=${api_key}" | jq -r '.result // "unknown"')
        local txn_count=$(curl -s "${api_base}/api?module=proxy&action=eth_getTransactionCount&address=${address}&tag=latest&apikey=${api_key}" | jq -r '.result // "unknown"')
        
        # Check if it's a contract at all
        local code=$(curl -s "${api_base}/api?module=proxy&action=eth_getCode&address=${address}&tag=latest&apikey=${api_key}" | jq -r '.result // "0x"')
        local is_contract="true"
        if [[ "$code" == "0x" || -z "$code" ]]; then
            is_contract="false"
        fi
        
        cat << EOF
{
  "address": "$address",
  "verified": false,
  "is_contract": $is_contract,
  "balance": "$balance",
  "transaction_count": "$(if [[ "$txn_count" != "unknown" && "$txn_count" != "null" ]]; then printf "%d" "$((10#$txn_count))" 2>/dev/null || echo "$txn_count"; else echo "unknown"; fi)",
  "message": "Contract source code not verified"
}
EOF
        return
    fi
    
    # Get source code details
    rate_limit
    local src_response=$(curl -s "${api_base}/api?module=contract&action=getsourcecode&address=${address}&apikey=${api_key}")
    
    local contract_name=$(echo "$src_response" | jq -r '.result[0].ContractName // "Unknown"')
    local compiler=$(echo "$src_response" | jq -r '.result[0].CompilerVersion // "Unknown"')
    local optimization=$(echo "$src_response" | jq -r '.result[0].OptimizationUsed // "0"')
    local runs=$(echo "$src_response" | jq -r '.result[0].Runs // "0"')
    local license=$(echo "$src_response" | jq -r '.result[0].LicenseType // "Unknown"')
    local proxy=$(echo "$src_response" | jq -r '.result[0].Proxy // "0"')
    local implementation=$(echo "$src_response" | jq -r '.result[0].Implementation // ""')
    
    cat << EOF
{
  "address": "$address",
  "verified": true,
  "contract_name": "$contract_name",
  "compiler_version": "$compiler",
  "optimization_enabled": $(if [[ "$optimization" == "1" ]]; then echo "true"; else echo "false"; fi),
  "optimization_runs": $runs,
  "license": "$license",
  "is_proxy": $(if [[ "$proxy" == "1" ]]; then echo "true"; else echo "false"; fi),
  "implementation_address": "$(if [[ -n "$implementation" && "$implementation" != "null" ]]; then echo "$implementation"; else echo "null"; fi)"
}
EOF
}

# Pretty print verification result
print_pretty() {
    local json_data="$1"
    local address=$(echo "$json_data" | jq -r '.address')
    local verified=$(echo "$json_data" | jq -r '.verified')
    
    echo -e "\n${BOLD}────────────────────────────────────────────${NC}"
    echo -e "${BOLD}Contract:${NC} ${CYAN}${address}${NC}"
    echo -e "${BOLD}Network:${NC}  ${NETWORK}"
    
    if [[ "$verified" == "true" ]]; then
        local name=$(echo "$json_data" | jq -r '.contract_name // "Unknown"')
        local compiler=$(echo "$json_data" | jq -r '.compiler_version // "Unknown"')
        local opt=$(echo "$json_data" | jq -r '.optimization_enabled')
        local runs=$(echo "$json_data" | jq -r '.optimization_runs')
        local license=$(echo "$json_data" | jq -r '.license // "Unknown"')
        local proxy=$(echo "$json_data" | jq -r '.is_proxy')
        local impl=$(echo "$json_data" | jq -r '.implementation_address')
        
        echo -e "${BOLD}Status:${NC}   ${GREEN}✓ VERIFIED${NC}"
        echo -e "${BOLD}Name:${NC}     ${name}"
        echo -e "${BOLD}Compiler:${NC} ${compiler}"
        
        if [[ "$opt" == "true" ]]; then
            echo -e "${BOLD}Optimize:${NC} ${GREEN}Enabled${NC} (${runs} runs)"
        else
            echo -e "${BOLD}Optimize:${NC} ${YELLOW}Disabled${NC}"
        fi
        
        echo -e "${BOLD}License:${NC}  ${license}"
        
        if [[ "$proxy" == "true" ]]; then
            echo -e "${BOLD}Proxy:${NC}    ${MAGENTA}Yes${NC}"
            if [[ -n "$impl" && "$impl" != "null" ]]; then
                echo -e "${BOLD}Impl:${NC}     ${CYAN}${impl}${NC}"
            fi
        fi
        
        echo -e "\n${BLUE}Etherscan:${NC} ${CYAN}https://${NETWORK}.etherscan.io/address/${address}#code${NC}"
    else
        local is_contract=$(echo "$json_data" | jq -r '.is_contract')
        local balance=$(echo "$json_data" | jq -r '.balance // "unknown"')
        local txn_count=$(echo "$json_data" | jq -r '.transaction_count // "0"')
        
        if [[ "$is_contract" == "false" ]]; then
            echo -e "${BOLD}Status:${NC}   ${YELLOW}⚠ EOA (Wallet)${NC}"
        else
            echo -e "${BOLD}Status:${NC}   ${RED}✗ NOT VERIFIED${NC}"
            echo -e "${DIM}This contract's source code is not publicly verified.${NC}"
            echo -e "${RED}⚠ USE WITH EXTREME CAUTION${NC}"
        fi
        
        if [[ "$balance" != "unknown" && "$balance" != "0" && -n "$balance" ]]; then
            local eth_bal=$(echo "scale=4; $balance / 1000000000000000000" | bc 2>/dev/null || echo "unknown")
            echo -e "${BOLD}Balance:${NC}  ${eth_bal} ETH"
        fi
        
        if [[ "$txn_count" != "unknown" && "$txn_count" != "0" && -n "$txn_count" ]]; then
            echo -e "${BOLD}Tx Count:${NC} ${txn_count}"
        fi
        
        echo -e "\n${BLUE}Etherscan:${NC} ${CYAN}https://${NETWORK}.etherscan.io/address/${address}${NC}"
    fi
}

# Deep analysis mode
deep_analysis() {
    local address="$1"
    local api_base="$2"
    local api_key="$3"
    
    echo -e "${BOLD}${CYAN}=== Deep Contract Analysis ===${NC}\n"
    
    local result=$(check_contract "$address" "$api_base" "$api_key")
    print_pretty "$result"
    
    # Check if proxy
    local is_proxy=$(echo "$result" | jq -r '.is_proxy')
    local impl=$(echo "$result" | jq -r '.implementation_address')
    
    if [[ "$is_proxy" == "true" && -n "$impl" && "$impl" != "null" && "$impl" != "" ]]; then
        echo -e "\n${YELLOW}🔍 Proxy detected. Checking implementation...${NC}\n"
        rate_limit
        local impl_result=$(check_contract "$impl" "$api_base" "$api_key")
        print_pretty "$impl_result"
    fi
}

# Compare two contracts
compare_contracts() {
    local addr1="$1"
    local addr2="$2"
    local api_base="$3"
    local api_key="$4"
    
    echo -e "${BOLD}${CYAN}=== Contract Comparison ===${NC}\n"
    
    local result1=$(check_contract "$addr1" "$api_base" "$api_key")
    local result2=$(check_contract "$addr2" "$api_base" "$api_key")
    
    print_pretty "$result1"
    print_pretty "$result2"
    
    echo -e "\n${BOLD}${CYAN}=== Comparison Summary ===${NC}\n"
    
    local name1=$(echo "$result1" | jq -r '.contract_name // "Unverified"')
    local name2=$(echo "$result2" | jq -r '.contract_name // "Unverified"')
    local ver1=$(echo "$result1" | jq -r '.verified')
    local ver2=$(echo "$result2" | jq -r '.verified')
    
    if [[ "$ver1" == "true" && "$ver2" == "true" ]]; then
        local comp1=$(echo "$result1" | jq -r '.compiler_version')
        local comp2=$(echo "$result2" | jq -r '.compiler_version')
        
        echo "Both contracts are verified"
        echo "  ${addr1:0:20}...: ${name1} (${comp1})"
        echo "  ${addr2:0:20}...: ${name2} (${comp2})"
        
        if [[ "$comp1" == "$comp2" ]]; then
            echo -e "\n  ${GREEN}✓ Same compiler version${NC}"
        else
            echo -e "\n  ${YELLOW}⚠ Different compiler versions${NC}"
        fi
    else
        echo -e "${YELLOW}Cannot compare - one or both contracts not verified${NC}"
    fi
}

# CSV export
export_csv() {
    local output_file="$1"
    shift
    local addresses=("$@")
    local api_base=$(get_api_url "$NETWORK")
    
    echo "address,network,verified,contract_name,compiler,optimization,license,is_proxy,message" > "$output_file"
    
    for addr in "${addresses[@]}"; do
        local result=$(check_contract "$addr" "$api_base" "$ETHERSCAN_API_KEY")
        echo "$result" | jq -r '[.address, "'"$NETWORK"'", .verified, .contract_name // "", .compiler_version // "", .optimization_enabled // "", .license // "", .is_proxy // "", .message // ""] | @csv' 2>/dev/null >> "$output_file"
    done
    
    echo -e "${GREEN}✅ Exported to $output_file${NC}"
}

# Main execution
# Parse arguments
ADDRESSES=()
BATCH_FILE=""
ANALYZE=false
COMPARE_MODE=false
ADDR1=""
ADDR2=""

while [[ $# -gt 0 ]]; do
    case $1 in
        -k|--key)
            ETHERSCAN_API_KEY="$2"
            shift 2
            ;;
        -n|--network)
            NETWORK="$2"
            shift 2
            ;;
        -f|--format)
            OUTPUT_FORMAT="$2"
            shift 2
            ;;
        -b|--batch)
            BATCH_FILE="$2"
            shift 2
            ;;
        -a|--analyze)
            ANALYZE=true
            shift
            ;;
        -c|--compare)
            COMPARE_MODE=true
            ADDR1="$2"
            ADDR2="$3"
            shift 3
            ;;
        --networks|-l|--list)
            list_networks
            exit 0
            ;;
        -j|--json)
            OUTPUT_FORMAT="json"
            shift
            ;;
        -h|--help)
            show_help
            exit 0
            ;;
        0x*)
            ADDRESSES+=("$1")
            shift
            ;;
        *)
            echo "Unknown option or address: $1"
            show_help
            exit 1
            ;;
    esac
done

# Check API key
if [[ -z "$ETHERSCAN_API_KEY" ]]; then
    echo -e "${RED}Error: Etherscan API key required${NC}"
    echo -e "Get one at: https://etherscan.io/apis"
    echo -e "Set ETHERSCAN_API_KEY environment variable or use -k flag\n"
    exit 1
fi

# Check dependencies
if ! command -v curl &>/dev/null; then
    echo -e "${RED}Error: 'curl' is required${NC}"
    exit 1
fi

if ! command -v jq &>/dev/null; then
    echo -e "${RED}Error: 'jq' is required. Install with: sudo apt-get install jq${NC}"
    exit 1
fi

# Get API URL
API_URL=$(get_api_url "$NETWORK")

# Load batch file if provided
if [[ -n "$BATCH_FILE" ]]; then
    if [[ ! -f "$BATCH_FILE" ]]; then
        echo -e "${RED}Error: Batch file not found: $BATCH_FILE${NC}"
        exit 1
    fi
    while IFS= read -r line; do
        line=$(echo "$line" | tr -d '[:space:]' | tr '[:upper:]' '[:lower:]')
        if [[ -n "$line" && "$line" != \#* ]]; then
            ADDRESSES+=("$line")
        fi
    done < "$BATCH_FILE"
fi

# No addresses?
if [[ ${#ADDRESSES[@]} -eq 0 && "$COMPARE_MODE" == false ]]; then
    echo -e "${RED}Error: No contract addresses provided${NC}"
    show_help
    exit 1
fi

# Show banner
if [[ "$OUTPUT_FORMAT" != "json" && "$OUTPUT_FORMAT" != "csv" && "$COMPARE_MODE" == false ]]; then
    echo -e "${CYAN}"
    cat << "EOF"
   ______            __             _______                        __
  / ____/___  ____  / /____  __    / ____(_)________  ____  ____  / /____
 / /   / __ \/ __ \/ //_/ / / /   / /_  / / ___/ __ \/ __ \/ __ \/ / ___/
/ /___/ /_/ / / / / ,< / /_/ /   / __/ / (__  ) /_/ / /_/ / /_/ / (__  ) 
\____/\____/_/ /_/_/|_|\__, /   /_/   /_/____/ .___/\____/\____/_/____/  
                      /____/                /_/
EOF
    echo -e "${NC}"
    echo -e "${DIM}Network: ${NETWORK} | API: ${API_URL}${NC}\n"
fi

# Handle compare mode
if [[ "$COMPARE_MODE" == true ]]; then
    compare_contracts "$ADDR1" "$ADDR2" "$API_URL" "$ETHERSCAN_API_KEY"
    exit 0
fi

# Process addresses
RESULTS=()
for addr in "${ADDRESSES[@]}"; do
    if "$ANALYZE"; then
        deep_analysis "$addr" "$API_URL" "$ETHERSCAN_API_KEY"
    else
        result=$(check_contract "$addr" "$API_URL" "$ETHERSCAN_API_KEY")
        
        if [[ "$OUTPUT_FORMAT" == "json" ]]; then
            RESULTS+=("$result")
        elif [[ "$OUTPUT_FORMAT" == "csv" ]]; then
            RESULTS+=("$result")
        else
            print_pretty "$result"
        fi
    fi
done

# JSON output
if [[ "$OUTPUT_FORMAT" == "json" ]]; then
    echo "["
    for i in "${!RESULTS[@]}"; do
        echo "${RESULTS[$i]}"
        if [[ $i -lt $((${#RESULTS[@]} - 1)) ]]; then
            echo ","
        fi
    done
    echo "]"
fi
