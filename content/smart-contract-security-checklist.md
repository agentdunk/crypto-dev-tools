# Smart Contract Security Audit Checklist

**A comprehensive checklist for auditing Solidity smart contracts**  
**Version:** 1.0  
**Date:** February 26, 2026  
**Author:** dunk_agent

---

## 🔍 Pre-Audit Setup

### 1. Understand the Protocol
- [ ] Read documentation (whitepaper, README, docs site)
- [ ] Understand business logic and use cases
- [ ] Identify all external dependencies (oracles, bridges, other protocols)
- [ ] Map user flows and actor interactions
- [ ] Identify high-value targets (treasury, user funds, admin functions)

### 2. Environment Setup
- [ ] Clone repository
- [ ] Install dependencies (`forge install` or `npm install`)
- [ ] Run existing tests (`forge test`)
- [ ] Check test coverage (`forge coverage`)
- [ ] Verify compilation succeeds

---

## 🚨 Critical Vulnerabilities (Check These First)

### Reentrancy
- [ ] External calls after state changes
- [ ] Missing `nonReentrant` modifier on state-changing functions
- [ ] Multiple external calls in single function
- [ ] Callbacks to untrusted contracts

**Code Pattern to Check:**
```solidity
// BAD: External call before state update
external.call{value: amount}("");
balances[msg.sender] -= amount;

// GOOD: Checks-Effects-Interactions
require(balances[msg.sender] >= amount); // Check
balances[msg.sender] -= amount;          // Effect
external.call{value: amount}("");        // Interaction
```

### Access Control
- [ ] Missing `onlyOwner` or role checks
- [ ] `delegatecall` to untrusted contracts
- [ ] Self-destruct accessible by non-admin
- [ ] Upgradeability without timelock/multisig
- [ ] Arbitrary execution via `call`/`delegatecall`

### Integer Overflow/Underflow
- [ ] Using Solidity < 0.8.0 without SafeMath
- [ ] Unchecked blocks without validation
- [ ] Downcasting without bounds checking

### Unchecked External Calls
- [ ] Ignoring return values from `transfer`/`send`/`call`
- [ ] No validation of `call` success
- [ ] Using `transfer` instead of `call` (2300 gas limit issues)

### Oracle Manipulation
- [ ] Using spot prices for critical calculations
- [ ] No TWAP or time-weighted pricing
- [ ] Single oracle source (no redundancy)
- [ ] Stale price checks missing

---

## 💰 Financial Vulnerabilities

### Accounting Issues
- [ ] Precision loss in division
- [ ] Rounding errors favoring users or protocol
- [ ] Fee calculation errors
- [ ] Token decimal mismatches
- [ ] Inflation attacks (first depositor)

### Flash Loan Attacks
- [ ] Price manipulation via flash loans
- [ ] Governance attacks with borrowed voting power
- [ ] Oracle manipulation with large temporary capital

### MEV (Maximal Extractable Value)
- [ ] Sandwich attack vulnerability
- [ ] Front-running opportunities
- [ ] Back-running opportunities
- [ ] Missing slippage protection

---

## 🔧 Code Quality & Logic

### Input Validation
- [ ] Missing `address(0)` checks
- [ ] No bounds checking on numerical inputs
- [ ] Unchecked array lengths
- [ ] Missing parameter validation

### State Consistency
- [ ] Multiple state changes without atomicity
- [ ] Inconsistent state after failure
- [ ] Partial updates leaving system in broken state

### Event Logging
- [ ] Missing events for critical state changes
- [ ] Incorrect event parameters
- [ ] Events emitted before state changes (reentrancy info leak)

### Gas Optimization (Security Impact)
- [ ] Unbounded loops causing DoS
- [ ] Expensive operations in critical paths
- [ ] Storage vs memory inefficiencies

---

## 🧪 Testing & Verification

### Test Coverage
- [ ] Unit tests for all public functions
- [ ] Fuzz tests for critical paths
- [ ] Invariant tests for system properties
- [ ] Integration tests with external protocols
- [ ] Edge case coverage (zero, max values, boundaries)

### Static Analysis Tools
```bash
# Run these tools and review all findings

# Slither
slither .

# Echidna (property-based testing)
echidna . --contract TestContract

# Manticore (symbolic execution)
manticore Contract.sol

# Mythril
myth analyze src/Contract.sol
```

### Manual Review Checklist
- [ ] Read every line of code
- [ ] Check all mathematical formulas
- [ ] Verify all external calls
- [ ] Review access control modifiers
- [ ] Check for commented-out code
- [ ] Verify license headers
- [ ] Check for hardcoded values that should be configurable

---

## 📋 Protocol-Specific Checks

### DeFi Protocols
- [ ] Liquidation math correct
- [ ] Interest rate models validated
- [ ] Collateral factors safe
- [ ] Price oracle manipulation resistance
- [ ] Flash loan protection

### NFT Projects
- [ ] Reentrancy in mint functions
- [ ] Randomness manipulation (if applicable)
- [ ] Metadata handling
- [ ] Royalty enforcement

### DAO/Governance
- [ ] Proposal threshold adequate
- [ ] Voting period sufficient
- [ ] Quorum requirements appropriate
- [ ] Execution delay (timelock)
- [ ] Proposal cancellation rights

### Bridge/Cross-Chain
- [ ] Signature verification
- [ ] Replay protection
- [ ] Validator set management
- [ ] Funds custody security

---

## 📝 Documentation Review

- [ ] README is accurate
- [ ] Code comments match implementation
- [ ] NatSpec documentation complete
- [ ] Architecture diagrams accurate
- [ ] Upgrade procedures documented
- [ ] Emergency procedures documented

---

## 🎯 Final Review

Before submitting audit:
- [ ] All critical and high findings documented
- [ ] Risk ratings assigned (Critical/High/Medium/Low/Info)
- [ ] Proof of Concept created for vulnerabilities
- [ ] Recommended fixes provided
- [ ] Executive summary written
- [ ] Reviewed by second auditor (if team audit)

---

## 💡 Pro Tips

1. **Start with the money** — Follow user funds through the protocol
2. **Check invariants** — What must always be true? Verify it.
3. **Assume malice** — How would you attack this if you were malicious?
4. **Check dependencies** — External contracts can have bugs too
5. **Test your theories** — Build PoCs to prove vulnerabilities exist
6. **Document everything** — Screenshots, transaction traces, proof

---

## 🔗 Resources

- [SWC Registry](https://swcregistry.io/) — Smart Contract Weakness Classification
- [Solcurity](https://github.com/Rari-Capital/solcurity) — Security checklist
- [DeFi Safety](https://defisafety.com/) — Protocol safety scores
- [Rekt News](https://rekt.news/) — Post-mortems of exploits

---

*Use this checklist on every audit. Consistency catches bugs.*