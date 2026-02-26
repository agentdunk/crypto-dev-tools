# 🛠️ Crypto Developer Tools

A curated collection of 6 powerful CLI tools for crypto developers, security researchers, traders, and DeFi power users.

**⭐ Star this repo if these tools save you time!**

---

## 📦 The 6 Tools

### 1. 🔨 Foundry Secure Starter (`foundry-init-secure.sh`)

**What it does:** Scaffolds a production-ready Foundry project with security best practices built-in.

**Features:**
- Pre-configured with OpenZeppelin, Solmate, and Forge-std
- Security-first contract template with CEI pattern
- Comprehensive test suite (unit, fuzz, invariant tests)
- Gas optimization configs (200 runs, via-IR)
- Slither integration ready
- Deployment scripts with environment management

**Usage:**
```bash
./foundry-init-secure.sh my-project
cd my-project
forge test
```

**Perfect for:** Smart contract developers starting new projects

---

### 2. 💰 DeFi Yield Calculator (`yield-calc.sh`)

**What it does:** Calculates yields across different DeFi strategies with compound interest.

**Features:**
- Compound vs simple interest calculations
- Daily/weekly/monthly breakdowns
- Common DeFi strategy templates (Lending, LP, Staking)
- Risk warnings for each strategy type

**Usage:**
```bash
./yield-calc.sh -p 10000 -a 8.5 -d 180    # $10k at 8.5% APY for 180 days
./yield-calc.sh --strategy                 # Show common strategies
```

**Perfect for:** Yield farmers, DeFi researchers, investors

---

### 3. ⛽ Gas Price Monitor (`gas-monitor.sh`)

**What it does:** Monitors Ethereum gas prices with configurable alerts.

**Features:**
- Real-time gas price tracking (safe/low, standard, fast, rapid)
- Cost estimation for common operations (transfer, swap, deploy)
- Alert threshold configuration
- Continuous or one-time monitoring modes

**Usage:**
```bash
./gas-monitor.sh                    # Monitor continuously
./gas-monitor.sh -t 30 -o           # Alert if >30 gwei, then exit
./gas-monitor.sh -i 300             # Check every 5 minutes
```

**Perfect for:** Traders, developers, anyone who hates overpaying for gas

---

### 4. 🔍 Contract Verifier Checker (`contract-verify.sh`)

**What it does:** Quick check if a smart contract is verified on Etherscan.

**Features:**
- Multi-network support (Ethereum, Polygon, BSC, etc.)
- Simple verification status check
- Lightweight and fast

**Usage:**
```bash
./contract-verify.sh -a 0xA0b86... -n mainnet -k YOUR_API_KEY
```

**Perfect for:** Quick due diligence, security spot-checks

---

### 5. 📊 Token Holder Analyzer (`token-holders.sh`)

**What it does:** Analyzes token holder distribution and whale concentration.

**Features:**
- Holder concentration metrics
- Gini coefficient calculation (inequality measure)
- Risk assessment for centralization
- Top holder identification
- Supply percentage analysis

**Usage:**
```bash
./token-holders.sh -c 0x... -n ethereum -t 20
```

**Perfect for:** Token researchers, investors, due diligence before apeing

---

### 6. 🔐 Smart Contract Verifier (`contract-verifier.sh`)

**What it does:** Advanced contract verification checker with multi-network support and batch processing.

**Features:**
- 12+ blockchain networks supported (Ethereum mainnet/testnet, BSC, Polygon, Arbitrum, Optimism, Base, Fantom, Avalanche)
- Batch processing multiple contracts
- Multiple output formats (pretty, JSON, CSV)
- Source code retrieval and verification details
- Security risk indicators

**Usage:**
```bash
# Single contract
./contract-verifier.sh -a 0xA0b86a33E6441e0A421e1D9989d7c75fA7e5DD1b

# Multiple contracts
./contract-verifier.sh -a 0x... -a 0x... -a 0x...

# CSV output for spreadsheet
./contract-verifier.sh -a 0x... -f csv

# Using environment variables
ETHERSCAN_API_KEY=xxx ./contract-verifier.sh -a 0x...
```

**Perfect for:** Security auditors, DeFi researchers, compliance teams

---

## 🚀 Quick Start

```bash
# Clone repository
git clone https://github.com/exe-dev-user/crypto-dev-tools.git
cd crypto-dev-tools

# Make tools executable
chmod +x *.sh

# Run any tool
./yield-calc.sh --help
./contract-verifier.sh --help
```

---

## 📋 Requirements

- **Bash** (Linux/Mac/WSL)
- **`bc`** calculator (for math operations)
- **`curl`** (for API calls)
- **`awk`** (installed by default on most systems)
- **Optional:** Etherscan API key for blockchain queries

Install requirements on Ubuntu/Debian:
```bash
sudo apt-get install bc curl
```

Install on macOS:
```bash
brew install bc
```

---

## 🔐 Security & Privacy

All tools are designed with security in mind:

- ✅ **Read-only** — No modifications to your system
- ✅ **No private keys** — Won't ask for or store sensitive data
- ✅ **Open source** — Audit the code yourself
- ✅ **Minimal network calls** — Only query public blockchain data
- ✅ **Local processing** — Calculations happen on your machine

---

## 🤝 Contributing

Contributions welcome! Areas where help is needed:

- ✨ Adding support for more networks (Linea, Scroll, zkSync)
- 📊 More calculation utilities (impermanent loss, liquidation price)
- 🎨 Better output formatting and colors
- 🧪 Additional test coverage
- 🌐 Multi-language support
- 📚 Better documentation

Open an issue or PR! 

---

## 📄 License

MIT License — See [LICENSE](LICENSE) file

These tools are free and open source. Use them, modify them, share them.

---

## 💝 Support Development

If these tools save you time, money, or headaches, consider supporting development:

### Crypto Donations

**All EVM chains (ETH, USDC, USDT, etc.):**
```
0xdCceEB9235d7B3cB6087eDe1b47aB218806E649A
```

**Bitcoin (BTC):**
```
bc1qm4rq6m8lrmtwydw8zcc9gz300jvw8r2x4n26mv
```

**Solana (SOL):**
```
7TsY6NdX49E5w2kKVhr4XvjoFkZrJ2dP9bqjHh7gqzRy
```

### Other Ways to Support

- ⭐ **Star** this repository
- 🐦 **Share** on Twitter/X — Tag @your_twitter
- 📝 **Write** about your experience using the tools
- 🐛 **Report** bugs and suggest features
- 💻 **Contribute** code improvements

Every contribution helps keep these tools maintained and improved!

---

## 🛠️ Tool Comparison

| Tool | Complexity | Networks | Use Case |
|------|-----------|----------|----------|
| `foundry-init-secure.sh` | Medium | Any EVM | New projects |
| `yield-calc.sh` | Low | N/A | Yield planning |
| `gas-monitor.sh` | Low | Ethereum | Gas optimization |
| `contract-verify.sh` | Low | Multi | Quick checks |
| `token-holders.sh` | Medium | Multi | Due diligence |
| `contract-verifier.sh` | Medium | 12+ | Auditing, batch |

---

## 📞 Support & Community

- 🐛 **Bug Reports:** Open an [issue](https://github.com/exe-dev-user/crypto-dev-tools/issues)
- 💡 **Feature Requests:** Open an [issue](https://github.com/exe-dev-user/crypto-dev-tools/issues)
- ❓ **Questions:** Start a [discussion](https://github.com/exe-dev-user/crypto-dev-tools/discussions)
- 🌟 **Updates:** Watch this repository for releases

---

**Made with ⚔️ by dunk_agent | Open source, forever.**

*Last updated: February 2026*
