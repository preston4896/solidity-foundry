# Foundry Solidity Template

Foundry template for bootstrapping Solidity projects. It ships with a deterministic **CREATE2 multichain deployment** system and a **P256 (secp256r1) signature verifier** utility out of the box, so you can focus on writing contracts rather than wiring infrastructure.

The `Calculator` contract is the reference starting point — replace it with your own contracts and use the provided scripts and utilities as-is.

---

## Project Structure

```
.
├── src/                        # Production contracts
│   └── Calculator.sol          # Example contract (replace with your own)
├── script/                     # Forge deployment scripts
│   ├── Calculator.s.sol        # Example deployment script (CREATE2)
│   └── utils/                  # Reusable script utilities
│       ├── DeploymentConfig.sol # Read/write deployed addresses per chain
│       ├── P256Configuration.sol # P256 verifier setup (RIP-7212 + Daimo)
│       └── Salt.sol            # Centralised CREATE2 salt definitions
├── test/                       # Forge tests
│   └── Calculator.t.sol        # Example test suite
├── deployment/                 # Auto-generated deployment address registry
│   └── <chainId>.json          # One file per chain (e.g. 31337.json)
├── lib/                        # Git submodule dependencies (e.g. forge-std)
├── .github/
│   └── workflows/
│       ├── ci.yml              # Build + test CI
│       └── slither.yml         # Slither static analysis
├── foundry.toml                # Foundry configuration
└── .env.example                # Environment variable template
```

---

## Provided Tools & Scripts

<details>
<summary><strong>Click to expand — utility documentation</strong></summary>

### `script/utils/DeploymentConfig.sol`

An abstract base contract for deployment scripts that reads and writes contract addresses to `deployment/<chainId>.json`.

- **`readContractAddress(name, revertOnAddressZero)`** — looks up a deployed address by contract name for the current chain. Reverts if the file is missing or the address is zero (when `revertOnAddressZero` is `true`).
- **`writeToJson(name, address)`** — persists a deployed address to the chain-specific JSON file. Only writes when `--broadcast` is active; dry-run simulations are silently skipped.

This design keeps your deployment registry append-only and safe from accidental overwrite during simulation runs.

### `script/utils/P256Configuration.sol`

Sets up a P256 (secp256r1/ WebAuthn) verifier for the target chain with a three-tier fallback strategy:

1. **RIP-7212 native precompile** (`0x000...0100`) — used when available (e.g. Optimism, Base, Polygon).
2. [**Daimo P256Verifier**](https://github.com/daimo-eth/p256-verifier) (`0xc2b7...`) — a known deployed verifier on chains that lack the precompile.
3. **Deploy Daimo via CREATE2** — falls back to deploying the verifier itself on local (`anvil`) or when `deployDaimo` is explicitly set to `true`.

Verifier detection is performed via FFI (`cast call`) so it works without touching chain state.

### `script/utils/Salt.sol`

Centralized store for all CREATE2 salts used across deployment scripts. Salts are defined as `bytes32 constant` values derived from `keccak256`, guaranteeing that the same contract address is produced on every supported chain.

Add a new constant here for each contract you add:

```solidity
bytes32 constant MY_CONTRACT_SALT = keccak256("MY_CONTRACT_SALT");
```

### `script/Calculator.s.sol`

Reference deployment script demonstrating the full CREATE2 + `DeploymentConfig` workflow:

```solidity
Calculator calculator = new Calculator{salt: CALCULATOR_SALT}(4896);
writeToJson("Calculator", address(calculator));
```

Copy this pattern for each new contract you deploy.

</details>

---

## Getting Started

### Prerequisites

Install [Foundry](https://book.getfoundry.sh/getting-started/installation):

```bash
curl -L https://foundry.paradigm.xyz | bash
foundryup
```

### Setup

```bash
# 1. Clone the repository
git clone <your-repo-url>
cd <repo-name>

# 2. Install submodule dependencies
git submodule update --init --recursive

# 3. Configure environment
cp .env.example .env
# Edit .env and fill in the RPC URLs for the networks you need
```

### Available Commands

| Command | Description |
|---|---|
| `forge build` | Compile all contracts |
| `forge test` | Run the test suite |
| `forge test --gas-report` | Run tests with gas usage report |
| `forge fmt` | Format all Solidity source files |
| `forge script script/Calculator.s.sol --broadcast --rpc-url <network>` | Deploy to a network |

**Deploy examples:**

```bash
# Deploy to local Anvil node
forge script script/Calculator.s.sol --broadcast --rpc-url anvil

# Deploy to Base Sepolia testnet
forge script script/Calculator.s.sol --broadcast --rpc-url base_sepolia

# Deploy to Ethereum mainnet
forge script script/Calculator.s.sol --broadcast --rpc-url mainnet
```

Network aliases (e.g. `anvil`, `base_sepolia`, `mainnet`) are defined in `foundry.toml` and resolve to the RPC URLs in your `.env` file.

---

## Multichain Deployment

This template uses **CREATE2** via the canonical `0x4e59b44847b379578588920cA78FbF26c0B4956C` factory to produce the same contract address on every EVM chain, as long as:

- The contract **bytecode** is identical across chains.
- The **salt** (defined in `script/utils/Salt.sol`) is identical across chains.

### Deployment registry

After each `--broadcast` run, `DeploymentConfig.writeToJson` appends the deployed address to `deployment/<chainId>.json`:

```json
{
  "Calculator": "0xabc...123"
}
```

This gives you a chain-indexed, version-controlled registry of every deployed contract address.

### Supported networks

The following networks are pre-configured in `foundry.toml`:

**Testnets:** Sepolia, Hoodi, Optimism Sepolia, Arbitrum Sepolia, Base Sepolia, World Sepolia, BSC Testnet, Polygon Amoy, Unichain Sepolia

**Mainnets:** Ethereum, Optimism, Arbitrum, Base, World, BSC, Polygon PoS, MegaETH

To add a new network, append an entry to the `[rpc_endpoints]` and `[etherscan]` sections of `foundry.toml` and add the corresponding `*_RPC_URL` variable to `.env`.

---

## CI/CD

Two GitHub Actions workflows run automatically:

| Workflow | Trigger | Description |
|---|---|---|
| `ci.yml` | Push / PR to `main` | Runs `forge build --sizes` and `forge test --gas-report` |
| `slither.yml` | PR to `main` (non-draft) | Runs [Slither](https://github.com/crytic/slither) static analysis and uploads SARIF results to GitHub Code Scanning |

---

## Contributing

1. Fork the repository and create a feature branch.
2. Make your changes and run `forge test` to verify nothing is broken.
3. Run `forge fmt` to ensure consistent formatting.
4. Open a pull request against `main` with a clear description of your changes.

Please keep pull requests focused — one feature or fix per PR.
