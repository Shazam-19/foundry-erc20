<a id="readme-top"></a>
# ERC20 Token

A Foundry-based ERC20 token project built with Solidity and OpenZeppelin. This repository demonstrates how to create, deploy, and test ERC20 tokens using industry-standard tooling while also providing a simplified manual token implementation for educational purposes.

---

## Table of Contents






<!-- TABLE OF CONTENTS -->
<details>
  <summary>Table of Contents</summary>
  <ol>
    <li><a href="#about-the-project">About The Project</a></li>
    <li><a href="#features">Features</a></li>
    <li><a href="#how-it-works">How It Works</a></li>
    <li><a href="#built-with">Built With</a></li>
    <li><a href="#project-structure">Project Structure</a></li>
    <li>
      <a href="#getting-started">Getting Started</a>
      <ul>
        <li><a href="#prerequisites">Prerequisites</a></li>
        <li><a href="#installation">Installation</a></li>
        <li><a href="#environment-variables">Environment Variables</a></li>
      </ul>
    </li>
    <li>
      <a href="#usage">Usage</a>
      <ul>
        <li><a href="#deploy-locally-anvil">Deploy Locally (Anvil)</a></li>
        <li><a href="#deploy-to-sepolia">Deploy to Sepolia</a></li>
        <li><a href="#deploy-to-zksync">Deploy to zkSync</a></li>
        <li><a href="#verify-contract">Verify Contract</a></li>
      </ul>
    </li>
    <li><a href="#running-tests">Running Tests</a></li>
    <li><a href="#contract-overview">Contract Overview</a></li>
      <ul>
        <li><a href="#ourtoken">OurToken</a></li>
        <li><a href="#manualtoken">ManualToken</a></li>
        <li><a href="#deployourtoken-script">DeployOurToken Script</a></li>
      </ul>
    <li><a href="#security-considerations">Security Considerations</a></li>
    <li><a href="#supported-networks">Supported Networks</a></li>
    <li><a href="#roadmap">Roadmap</a></li>
    <li><a href="#contributing">Contributing</a></li>
    <li><a href="#license">License</a></li>
    <li><a href="#author">Author</a></li>
    <li><a href="#acknowledgments">Acknowledgments</a></li>
  </ol>
</details>

<p align="right">(<a href="#readme-top">back to top</a>)</p>

---

## About The Project

This project demonstrates the implementation, deployment, and testing of ERC20 tokens using Solidity, OpenZeppelin, and Foundry.

It contains two token implementations:

* **OurToken** — a production-style ERC20 token built on OpenZeppelin's battle-tested ERC20 standard.
* **ManualToken** — a simplified token implementation created for educational purposes to demonstrate the underlying mechanics of balances and transfers.

The repository also includes deployment scripts, automated testing, fuzz testing, and multi-network deployment support.

### Key Highlights

* **ERC20 compliant** — built on OpenZeppelin's widely used ERC20 implementation.
* **Comprehensive testing** — includes unit tests, event verification, allowance testing, and fuzz testing.
* **Production deployment workflow** — deploy locally, on Sepolia, or on zkSync using Foundry scripts.
* **Educational comparison** — includes a manually implemented token contract to demonstrate token fundamentals.
* **Multi-network support** — deploy and test across multiple EVM-compatible environments.

<p align="right">(<a href="#readme-top">back to top</a>)</p>

---

## Features

* 🪙 **ERC20 Standard Token** — inherits OpenZeppelin's ERC20 implementation with support for transfers, approvals, allowances, and delegated spending.
* 🚀 **Automated Deployment Scripts** — deploy tokens consistently using Foundry scripts.
* 🧪 **Comprehensive Test Suite** — unit tests, event validation, allowance testing, and fuzz testing.
* 🔐 **OpenZeppelin Security** — leverages audited and battle-tested ERC20 contracts.
* 🎯 **Allowance & Approval Testing** — validates delegated token transfers using `approve()` and `transferFrom()`.
* 📢 **Event Verification** — confirms proper emission of `Transfer` and `Approval` events.
* 🌐 **Multi-Network Support** — deploy locally, on Sepolia, and on zkSync.
* 📚 **Educational Token Implementation** — includes a manual token contract for learning token mechanics without external libraries.

<p align="right">(<a href="#readme-top">back to top</a>)</p>

---

## How It Works

### OurToken

1. Inherits OpenZeppelin's ERC20 implementation.
2. Receives an initial supply during deployment.
3. Mints the entire supply to the deployer.
4. Supports standard ERC20 transfers.
5. Supports approvals and delegated transfers.
6. Emits standard ERC20 events.

### ManualToken

1. Stores balances in a mapping.
2. Implements a simplified transfer mechanism.
3. Performs balance invariant checks.
4. Omits approvals, allowances, and events to focus on core token concepts.
5. Intended for educational purposes only and not production use.

<p align="right">(<a href="#readme-top">back to top</a>)</p>

---

## Built With

* Solidity `^0.8.26`
* Foundry
* OpenZeppelin Contracts
* forge-std
* foundry-devops

<p align="right">(<a href="#readme-top">back to top</a>)</p>

---

## Project Structure

```text
erc20-token/
├── foundry.toml
├── Makefile
├── README.md
│
├── src/
│   ├── OurToken.sol
│   └── ManualToken.sol
│
├── script/
│   └── DeployOurToken.s.sol
│
├── test/
│   └── OurToken.t.sol
│
└── lib/
    ├── forge-std/
    ├── foundry-devops/
    └── openzeppelin-contracts/
```

> Run `tree -L 2` in your project root to verify your local structure matches.

<p align="right">(<a href="#readme-top">back to top</a>)</p>

---

## Getting Started

### Prerequisites

Before beginning, ensure you have:

* Foundry installed
* Git installed
* A Sepolia RPC endpoint
* A funded wallet for deployments
* An Etherscan API key (optional, for verification)

Verify your Foundry installation:

```sh
forge --version
```

### Installation

Clone the repository:

```sh
git clone <YOUR_REPOSITORY_URL>
cd <YOUR_REPOSITORY_NAME>
```

Install dependencies:

```sh
forge install
```

Or use the Makefile:

```sh
make install
```

Build the project:

```sh
forge build
```

Or:

```sh
make build
```

### Environment Variables

Create a `.env` file in the project root:

```env
SEPOLIA_RPC_URL="your_sepolia_rpc_url"
ETH_MAINNET_RPC_URL="your_alchemy_rpc_url"
ZKSYNC_SEPOLIA_RPC_URL="your_zksync_rpc_url"
ALCHEMY_API_KEY="your_alchemy_api_key"
ETHERSCAN_API_KEY="your_etherscan_api_key"
PRIVATE_KEY="your_wallet_private_key"
DEPLOYED_CONTRACT_ADDRESS="deployed_contract_address_on_sepolia"
```

> ⚠️ Never commit your private key or `.env` file to source control.

<p align="right">(<a href="#readme-top">back to top</a>)</p>

---

## Usage

### Deploy Locally (Anvil)

Start a local Anvil node:

```sh
make anvil
```

Deploy the token:

```sh
make deploy-local
```

### Deploy to Sepolia

Configure your `.env` file and run:

```sh
make deploy-sepolia
```

### Deploy to zkSync

Deploy to a local zkSync environment:

```sh
make deploy-zk
```

Deploy to zkSync Sepolia:

```sh
make deploy-zk-sepolia
```

### Verify Contract

Verify a deployed contract on Sepolia:

```sh
make verify
```

<p align="right">(<a href="#readme-top">back to top</a>)</p>

---

## Running Tests

Run the complete test suite:

```sh
forge test
```

Or:

```sh
make test
```

Run tests with verbose output:

```sh
forge test -vvv
```

Generate a gas snapshot:

```sh
make snapshot
```

Run zkSync-compatible tests:

```sh
make test-zk
```

Format the codebase:

```sh
make format
```

<p align="right">(<a href="#readme-top">back to top</a>)</p>

---

## Contract Overview

### OurToken

`OurToken.sol` is the primary ERC20 implementation.

Key characteristics:

* Inherits OpenZeppelin's ERC20 contract.
* Uses the token name **"Our Token"**.
* Uses the token symbol **"OT"**.
* Uses the standard 18 decimal places.
* Mints the entire initial supply to the deployer during construction.

Constructor:

```solidity
constructor(uint256 initialSupply) ERC20("Our Token", "OT") {
    _mint(msg.sender, initialSupply);
}
```

### ManualToken

`ManualToken.sol` demonstrates token mechanics without relying on OpenZeppelin.

Features:

* Manual balance tracking.
* Fixed total supply.
* Basic transfer functionality.
* Balance invariant checks.
* Educational implementation.

Limitations:

* Not ERC20 compliant.
* No approvals.
* No allowances.
* No transfer events.
* Not suitable for production use.

### DeployOurToken Script

`DeployOurToken.s.sol` handles deployment using Foundry scripts.

Default initial supply:

```solidity
uint256 public constant INITIAL_SUPPLY = 1000 ether;
```

Deployment flow:

1. Start broadcasting transactions.
2. Deploy `OurToken`.
3. Mint the initial supply to the deployer.
4. Stop broadcasting.

<p align="right">(<a href="#readme-top">back to top</a>)</p>

---

## Security Considerations

### OurToken

Because `OurToken` inherits OpenZeppelin's ERC20 implementation, it benefits from:

* Extensive community review.
* Industry adoption.
* Standard-compliant behavior.
* Built-in overflow and underflow protection from Solidity 0.8+.

### ManualToken

`ManualToken` is intentionally simplified and should not be used in production.

Missing features include:

* ERC20 compliance.
* Approval mechanisms.
* Transfer events.
* Permit functionality.
* Advanced security considerations.

Always use audited implementations such as OpenZeppelin for production deployments.

<p align="right">(<a href="#readme-top">back to top</a>)</p>

---

## Supported Networks

The Makefile currently supports deployment to:

| Network        | Supported |
| -------------- | --------- |
| Local Anvil    | ✅         |
| Sepolia        | ✅         |
| zkSync Local   | ✅         |
| zkSync Sepolia | ✅         |

Additional EVM-compatible networks can be added by updating deployment scripts and environment variables.

<p align="right">(<a href="#readme-top">back to top</a>)</p>

---

## Roadmap

Potential future improvements:

* [ ] ERC20 Permit (EIP-2612)
* [ ] Token burning functionality
* [ ] Role-based minting controls
* [ ] Access control using OpenZeppelin AccessControl
* [ ] Deployment automation via CI/CD
* [ ] Additional integration tests
* [ ] Mainnet deployment support
* [ ] Coverage reporting

<p align="right">(<a href="#readme-top">back to top</a>)</p>

---

## Contributing

Contributions are what make the open source community such an amazing place to learn and grow. Any contributions you make are **greatly appreciated**.

If you have a suggestion that would improve this project, please fork the repo and open a pull request. You can also open an issue with the tag `enhancement`.

1. Fork the repository
2. Create your feature branch:
```sh
git checkout -b feature/YourFeature
```
3. Commit your changes following the [Conventional Commits](https://www.conventionalcommits.org/) format:
```sh
git commit -m "feat: add your feature description"
```
4. Push to your branch:
```sh
git push origin feature/YourFeature
```
5. Open a Pull Request

### Commit Prefix Guide

| Prefix | Use for |
|--------|---------|
| `feat` | New feature or function |
| `fix` | Bug fix |
| `docs` | Documentation or comments only |
| `refactor` | Code restructuring without behaviour change |
| `test` | Adding or updating tests |
| `chore` | Maintenance tasks (config, dependencies) |

<p align="right">(<a href="#readme-top">back to top</a>)</p>

---

## License

This project is licensed under the MIT License.

See the SPDX license identifiers in the source files for details.

<p align="right">(<a href="#readme-top">back to top</a>)</p>

---

## Author

**Abdelrahman Sayed**

<p align="right">(<a href="#readme-top">back to top</a>)</p>

---

## Acknowledgments

* OpenZeppelin for the ERC20 implementation.
* Foundry for the development and testing framework.
* Cyfrin for educational resources and tooling.
* The Ethereum community for ERC20 standards and best practices.

<p align="right">(<a href="#readme-top">back to top</a>)</p>

