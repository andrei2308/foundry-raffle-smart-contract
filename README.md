# Foundry Raffle Smart Contract

This repository contains a smart contract for a decentralized raffle system, built using Foundry. The project allows users to enter a raffle, and a winner is selected at random using Chainlink VRF (Verifiable Random Function). Currently, the contract is designed to run only on a local blockchain network.

---

## Features

- **Decentralized Raffle:** Users can participate by sending ETH to the contract.
- **Random Winner Selection:** The winner is selected randomly using Chainlink VRF.
- **Secure and Transparent:** The use of verifiable randomness ensures fairness.

---

## Prerequisites

To run this project, ensure you have the following installed:

- [Foundry](https://book.getfoundry.sh/) - A blazing fast, portable, and modular toolkit for Ethereum development written in Rust.
- A local blockchain like [Anvil](https://book.getfoundry.sh/anvil/) or [Hardhat Network](https://hardhat.org/).

---

## Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/andrei2308/foundry-raffle-smart-contract.git
   cd foundry-raffle-smart-contract
   ```

2. Install dependencies:
   ```bash
   forge install
   ```

3. Compile the contracts:
   ```bash
   forge build
   ```

4. Run tests:
   ```bash
   forge test
   ```

---

## Usage

### Deploying the Contract
1. Start a local blockchain (e.g., Anvil):
   ```bash
   anvil
   ```

2. Deploy the contract using Foundry:
   ```bash
   forge script script/DeployRaffle.s.sol:DeployRaffle --broadcast --fork-url http://127.0.0.1:8545
   ```

### Interacting with the Contract
1. Connect your wallet to the local blockchain.
2. Use the deployed contract's address to interact with it via scripts, a frontend, or tools like [Ethers.js](https://docs.ethers.io/).

---

## Current Limitations

- **Local Chain Only:** The contract is currently designed to work exclusively on a local blockchain. It does not support testnets (e.g., Sepolia, Goerli) or the Ethereum mainnet at this time.
- **Chainlink Integration:** The Chainlink VRF implementation is simulated using mocks for local development. Real Chainlink VRF integration requires deployment on testnets or mainnet with an active subscription.

---

## Future Enhancements

- Add support for Ethereum testnets and mainnet.
- Improve the frontend for a better user experience.
- Enhance testing with real Chainlink VRF on supported networks.

---

## Contributing

Contributions are welcome! To contribute:
1. Fork the repository.
2. Create a feature branch.
3. Submit a pull request with a clear description of your changes.

---

## License

This project is licensed under the [MIT License](LICENSE).

---

## Acknowledgments

- [Foundry](https://github.com/foundry-rs/foundry)
- [Chainlink VRF](https://docs.chain.link/docs/vrf/v2/introduction/)
- [Anvil](https://book.getfoundry.sh/anvil/)

Feel free to explore and improve the project! 😊
