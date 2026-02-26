#!/bin/bash
# Foundry Secure Project Generator
# Usage: ./foundry-init-secure.sh <project-name>

set -e

PROJECT_NAME=${1:-"my-project"}

echo "🔨 Creating secure Foundry project: $PROJECT_NAME"

# Initialize Foundry project
forge init $PROJECT_NAME --no-commit
cd $PROJECT_NAME

# Install security-focused dependencies
echo "📦 Installing security dependencies..."
forge install OpenZeppelin/openzeppelin-contracts --no-commit
forge install foundry-rs/forge-std --no-commit
forge install Transmissions11/solmate --no-commit

# Create secure project structure
mkdir -p src/{utils,interfaces,libs}
mkdir -p test/{fuzz,invariant,integration}
mkdir -p script
cat > .gitignore << 'EOF'
# Foundry
cache/
out/
broadcast/

# IDE
.vscode/
.idea/
*.swp
*.swo

# OS
.DS_Store
Thumbs.db

# Secrets
.env
.env.local
*.key
*.pem
EOF

# Create security-focused foundry.toml
cat > foundry.toml << 'EOF'
[profile.default]
src = "src"
test = "test"
script = "script"
out = "out"
cache_path = "cache"
libs = ["lib"]

# Security settings
optimizer = true
optimizer_runs = 200
via_ir = true

# Testing
fuzz_runs = 10000
invariant_runs = 1000
invariant_depth = 100

# Gas reporting
gas_reports = ["*"]
gas_reports_ignore = []

[fmt]
line_length = 100
EOF

# Create secure contract template
cat > src/SecureContractTemplate.sol << 'EOF'
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/security/Pausable.sol";

/**
 * @title SecureContractTemplate
 * @notice Template with security best practices built-in
 * @dev Follows: Checks-Effects-Interactions, ReentrancyGuard, Pausable
 */
contract SecureContractTemplate is Ownable, ReentrancyGuard, Pausable {
    
    // ============ Errors ============
    error InvalidAddress();
    error InvalidAmount();
    error InsufficientBalance();
    error OperationFailed();
    
    // ============ Events ============
    event Deposited(address indexed user, uint256 amount);
    event Withdrawn(address indexed user, uint256 amount);
    
    // ============ State Variables ============
    mapping(address => uint256) public balances;
    
    // ============ Modifiers ============
    modifier validAddress(address _addr) {
        if (_addr == address(0)) revert InvalidAddress();
        _;
    }
    
    modifier validAmount(uint256 _amount) {
        if (_amount == 0) revert InvalidAmount();
        _;
    }
    
    // ============ Constructor ============
    constructor() Ownable(msg.sender) {}
    
    // ============ External Functions ============
    
    /**
     * @notice Deposit ETH into contract
     * @dev Uses Checks-Effects-Interactions pattern
     */
    function deposit() external payable nonReentrant whenNotPaused validAmount(msg.value) {
        // Effects
        balances[msg.sender] += msg.value;
        
        // Emit event
        emit Deposited(msg.sender, msg.value);
    }
    
    /**
     * @notice Withdraw ETH from contract
     * @param _amount Amount to withdraw
     * @dev CEI pattern + ReentrancyGuard
     */
    function withdraw(uint256 _amount) 
        external 
        nonReentrant 
        whenNotPaused 
        validAmount(_amount) 
    {
        // Checks
        if (balances[msg.sender] < _amount) revert InsufficientBalance();
        
        // Effects
        balances[msg.sender] -= _amount;
        
        // Interactions (last)
        (bool success, ) = payable(msg.sender).call{value: _amount}("");
        if (!success) revert OperationFailed();
        
        emit Withdrawn(msg.sender, _amount);
    }
    
    // ============ Admin Functions ============
    
    function pause() external onlyOwner {
        _pause();
    }
    
    function unpause() external onlyOwner {
        _unpause();
    }
    
    // ============ View Functions ============
    
    function getBalance(address _user) external view returns (uint256) {
        return balances[_user];
    }
}
EOF

# Create comprehensive test template
cat > test/SecureContractTemplate.t.sol << 'EOF'
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/SecureContractTemplate.sol";

contract SecureContractTemplateTest is Test {
    SecureContractTemplate public contractUnderTest;
    
    address public owner = address(1);
    address public user1 = address(2);
    address public user2 = address(3);
    
    function setUp() public {
        vm.prank(owner);
        contractUnderTest = new SecureContractTemplate();
        
        // Fund users
        vm.deal(user1, 100 ether);
        vm.deal(user2, 100 ether);
    }
    
    // ============ Deposit Tests ============
    
    function test_Deposit() public {
        uint256 depositAmount = 1 ether;
        
        vm.prank(user1);
        contractUnderTest.deposit{value: depositAmount}();
        
        assertEq(contractUnderTest.getBalance(user1), depositAmount);
    }
    
    function test_Deposit_Revert_ZeroAmount() public {
        vm.prank(user1);
        vm.expectRevert(SecureContractTemplate.InvalidAmount.selector);
        contractUnderTest.deposit{value: 0}();
    }
    
    function test_Deposit_EventEmitted() public {
        uint256 depositAmount = 1 ether;
        
        vm.prank(user1);
        vm.expectEmit(true, true, false, true);
        emit SecureContractTemplate.Deposited(user1, depositAmount);
        contractUnderTest.deposit{value: depositAmount}();
    }
    
    // ============ Withdraw Tests ============
    
    function test_Withdraw() public {
        uint256 depositAmount = 1 ether;
        uint256 withdrawAmount = 0.5 ether;
        
        // Setup: deposit first
        vm.prank(user1);
        contractUnderTest.deposit{value: depositAmount}();
        
        // Withdraw
        uint256 balanceBefore = user1.balance;
        vm.prank(user1);
        contractUnderTest.withdraw(withdrawAmount);
        
        // Assert
        assertEq(contractUnderTest.getBalance(user1), depositAmount - withdrawAmount);
        assertEq(user1.balance, balanceBefore + withdrawAmount);
    }
    
    function test_Withdraw_Revert_InsufficientBalance() public {
        vm.prank(user1);
        vm.expectRevert(SecureContractTemplate.InsufficientBalance.selector);
        contractUnderTest.withdraw(1 ether);
    }
    
    function test_Withdraw_Revert_ZeroAmount() public {
        vm.prank(user1);
        vm.expectRevert(SecureContractTemplate.InvalidAmount.selector);
        contractUnderTest.withdraw(0);
    }
    
    // ============ Pause Tests ============
    
    function test_Pause() public {
        vm.prank(owner);
        contractUnderTest.pause();
        
        vm.prank(user1);
        vm.expectRevert("Pausable: paused");
        contractUnderTest.deposit{value: 1 ether}();
    }
    
    function test_Pause_Revert_NotOwner() public {
        vm.prank(user1);
        vm.expectRevert();
        contractUnderTest.pause();
    }
    
    // ============ Fuzz Tests ============
    
    function testFuzz_Deposit(uint256 amount) public {
        vm.assume(amount > 0 && amount < 1000 ether);
        
        vm.prank(user1);
        contractUnderTest.deposit{value: amount}();
        
        assertEq(contractUnderTest.getBalance(user1), amount);
    }
    
    function testFuzz_DepositWithdraw(uint256 depositAmount, uint256 withdrawAmount) public {
        vm.assume(depositAmount > 0 && depositAmount < 1000 ether);
        vm.assume(withdrawAmount > 0 && withdrawAmount <= depositAmount);
        
        vm.prank(user1);
        contractUnderTest.deposit{value: depositAmount}();
        
        vm.prank(user1);
        contractUnderTest.withdraw(withdrawAmount);
        
        assertEq(contractUnderTest.getBalance(user1), depositAmount - withdrawAmount);
    }
}
EOF

# Create fuzz test template
cat > test/fuzz/FuzzSecureContract.sol << 'EOF'
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../../src/SecureContractTemplate.sol";

contract FuzzSecureContract is Test {
    SecureContractTemplate public target;
    
    function setUp() public {
        target = new SecureContractTemplate();
    }
    
    function testFuzz_Deposit(uint256 amount) public {
        vm.assume(amount > 0);
        
        uint256 balanceBefore = address(target).balance;
        
        target.deposit{value: amount}();
        
        assertEq(address(target).balance, balanceBefore + amount);
    }
}
EOF

# Create invariant test template
cat > test/invariant/InvariantSecureContract.t.sol << 'EOF'
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../../src/SecureContractTemplate.sol";

contract InvariantSecureContract is Test {
    SecureContractTemplate public target;
    
    function setUp() public {
        target = new SecureContractTemplate();
    }
    
    function invariant_BalanceMatchesDeposits() public {
        // Contract balance should equal sum of all user balances
        // This is a placeholder - implement actual invariant
    }
}
EOF

# Create deployment script
cat > script/Deploy.s.sol << 'EOF'
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "../src/SecureContractTemplate.sol";

contract DeployScript is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        
        vm.startBroadcast(deployerPrivateKey);
        
        SecureContractTemplate contractInstance = new SecureContractTemplate();
        
        vm.stopBroadcast();
        
        console.log("Contract deployed at:", address(contractInstance));
    }
}
EOF

# Create .env.example
cat > .env.example << 'EOF'
# RPC Endpoints
MAINNET_RPC_URL=https://eth-mainnet.g.alchemy.com/v2/YOUR_API_KEY
SEPOLIA_RPC_URL=https://eth-sepolia.g.alchemy.com/v2/YOUR_API_KEY

# Deployment
PRIVATE_KEY=0x...
ETHERSCAN_API_KEY=YOUR_API_KEY

# Testing
FORK_BLOCK_NUMBER=latest
EOF

# Create SECURITY.md
cat > SECURITY.md << 'EOF'
# Security Checklist

## Pre-Deployment
- [ ] All tests passing (`forge test`)
- [ ] Fuzz tests run for 10k+ iterations
- [ ] Slither analysis clean
- [ ] Manual code review complete
- [ ] Documentation updated

## Static Analysis
```bash
# Run Slither
slither .

# Run Mythril (optional)
myth analyze src/Contract.sol
```

## Test Coverage
```bash
# Run all tests
forge test

# Run with gas reporting
forge test --gas-report

# Run fuzz tests
forge test --match-contract Fuzz

# Run invariant tests
forge test --match-contract Invariant
```

## Deployment
```bash
# Source .env
source .env

# Dry run
forge script script/Deploy.s.sol --rpc-url $SEPOLIA_RPC_URL --broadcast --verify -vvvv

# Production
forge script script/Deploy.s.sol --rpc-url $MAINNET_RPC_URL --broadcast --verify -vvvv
```
EOF

# Create README
cat > README.md << 'EOF'
# Secure Foundry Project Template

A production-ready template for secure smart contract development with Foundry.

## Features

- ✅ Security-first architecture
- ✅ OpenZeppelin integrations
- ✅ Comprehensive test suite
- ✅ Fuzz and invariant tests
- ✅ Gas optimization configs
- ✅ Deployment scripts
- ✅ Security checklist

## Quick Start

```bash
# Install dependencies
forge install

# Run tests
forge test

# Run with gas report
forge test --gas-report

# Deploy to testnet
forge script script/Deploy.s.sol --rpc-url $SEPOLIA_RPC_URL --broadcast
```

## Project Structure

```
src/
  ├── SecureContractTemplate.sol    # Main contract with security patterns
  ├── utils/                         # Utility contracts
  ├── interfaces/                    # Interface definitions
  └── libs/                          # Library contracts

test/
  ├── SecureContractTemplate.t.sol   # Main test suite
  ├── fuzz/                          # Fuzz tests
  ├── invariant/                     # Invariant tests
  └── integration/                   # Integration tests

script/
  └── Deploy.s.sol                   # Deployment scripts
```

## Security Patterns Used

1. **Checks-Effects-Interactions** — Prevent reentrancy
2. **ReentrancyGuard** — Additional reentrancy protection
3. **Pausable** — Emergency stop functionality
4. **Ownable** — Access control
5. **Custom Errors** — Gas-efficient error handling
6. **Events** — Off-chain monitoring

## License

MIT
EOF

echo ""
echo "✅ Secure Foundry project created: $PROJECT_NAME"
echo ""
echo "Next steps:"
echo "  cd $PROJECT_NAME"
echo "  cp .env.example .env"
echo "  # Edit .env with your values"
echo "  forge test"
echo ""
echo "🔒 Security-first development starts now!"
