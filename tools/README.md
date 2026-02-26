# 🛠️ Crypto Developer Tools

A collection of CLI tools for crypto developers, traders, and researchers.

All tools are open source, MIT licensed, and free to use. If you find them valuable, consider supporting development:

**Support:** [Add your donation address here]

---

## 📦 Tools

### 1. Foundry Secure Starter (`foundry-init-secure.sh`)

**What it does:** Scaffolds a secure Foundry project with best practices built-in.

**Features:**
- Pre-configured with OpenZeppelin, Solmate
- Security-first contract template
- Comprehensive test suite (unit, fuzz, invariant)
- Slither and security checklist included
- Gas optimization configs

**Usage:**
```bash
./foundry-init-secure.sh my-project
cd my-project
forge test
```

**Perfect for:** Developers starting new smart contract projects

---

### 2. DeFi Yield Calculator (`yield-calc.sh`)

**What it does:** Calculates yields across different DeFi strategies.

**Features:**
- Compound vs simple interest
- Daily/weekly/monthly breakdowns
- Common strategy templates
- Risk warnings

**Usage:**
```bash
./yield-calc.sh -p 10000 -a 8.5 -d 180
./yield-calc.sh --strategy  # Show common strategies
```

**Perfect for:** Yield farmers, DeFi researchers

---

### 3. Gas Price Monitor (`gas-monitor.sh`)

**What it does:** Monitors Ethereum gas prices and alerts on spikes.

**Features:**
- Real-time gas price tracking
- Cost estimation for common operations
- Alert threshold configuration
- Continuous or one-time mode

**Usage:**
```bash
./gas-monitor.sh                    # Monitor continuously
./gas-monitor.sh -t 30 -o           # Alert if >30 gwei
./gas-monitor.sh -i 300             # Check every 5 min
```

**Perfect for:** Traders, developers, anyone who cares about gas costs

---

### 4. Contract Verifier Checker (`contract-verify.sh`)

**What it does:** Checks if a smart contract is verified on Etherscan.

**Features:**
- Multi-network support (Ethereum, Polygon, etc.)
- Verification status check
- Security indicators

**Usage:**
```bash
./contract-verify.sh -a 0xA0b86... -n mainnet -k YOUR_API_KEY
```

**Perfect for:** Security researchers, due diligence

---

### 5. Token Holder Analyzer (`token-holders.sh`)

**What it does:** Analyzes token holder distribution and whale concentration.

**Features:**
- Holder concentration metrics
- Gini coefficient calculation
- Risk assessment
- Top holder identification

**Usage:**
```bash
./token-holders.sh -c 0x... -n ethereum -t 20
```

**Perfect for:** Token researchers, investors, due diligence

---

## 🚀 Quick Start

```bash
# Clone repository
git clone https://github.com/yourusername/crypto-dev-tools.git
cd crypto-dev-tools

# Make tools executable
chmod +x *.sh

# Run any tool
./yield-calc.sh --help
```

---

## 📋 Requirements

- Bash shell (Linux/Mac/WSL)
- `bc` calculator (for math operations)
- `curl` (for API calls)
- Optional: Etherscan API key for verification tools

Install requirements on Ubuntu/Debian:
```bash
sudo apt-get install bc curl
```

---

## 🛡️ Security

All tools are:
- ✅ Read-only (don't modify your system)
- ✅ No private key handling
- ✅ Open source (audit the code)
- ✅ No network calls (except where noted)

---

## 🤝 Contributing

Contributions welcome! Areas where help is needed:
- Adding support for more networks
- Improving calculation accuracy
- Adding new tools
- Better documentation

---

## 📄 License

MIT License - See LICENSE file

---

## 💝 Support

These tools are free and open source. If they save you time or money:

**ETH/USDC:** `0x...`  
**SOL:** `...`  
**BTC:** `...`

Or support by:
- ⭐ Starring the repo
- 🐦 Sharing on Twitter
- 📝 Writing about your experience

---

**Made with ⚔️ by dunk_agent**
