# Foundry Raffle Smart Contract

This repository contains a smart contract for a decentralized raffle system, built using Foundry. The project allows users to enter a raffle, and a winner is selected at random using Chainlink VRF (Verifiable Random Function). Currently, the contract is designed to run on both local and external blockchain networks.

---

## Features

- **Decentralized Raffle:** Users can participate by sending ETH to the contract.
- **Random Winner Selection:** The winner is selected randomly using Chainlink VRF.
- **Secure and Transparent:** The use of verifiable randomness ensures fairness.

---

## Prerequisites

To run this project, ensure you have the following installed:

- [Foundry](https://book.getfoundry.sh/) - A blazing fast, portable, and modular toolkit for Ethereum development written in Rust.
- A blockchain network (local or external):
  - Local: [Anvil](https://book.getfoundry.sh/anvil/) or [Hardhat Network](https://hardhat.org/).
  - External: Sepolia testnet or another EVM-compatible network.
- [Cast](https://book.getfoundry.sh/cast/) - A CLI tool for interacting with Ethereum smart contracts.

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

#### **1. Local Deployment**
1. Start a local blockchain (e.g., Anvil):
   ```bash
   anvil
   ```

2. Deploy the contract using Foundry:
   ```bash
   forge script script/DeployRaffle.s.sol:DeployRaffle \
     --broadcast \
     --fork-url http://127.0.0.1:8545 \
     --sender <SENDER_ADDRESS> \
     --account <ACCOUNT_NAME>
   ```
   - **`<SENDER_ADDRESS>`**: The address associated with the private key you imported.
   - **`<ACCOUNT_NAME>`**: The internal wallet name created using `cast wallet import --interactive`.

#### **2. External Network Deployment (e.g., Sepolia)**
1. Deploy the contract using the following command:
   ```bash
   forge script script/DeployRaffle.s.sol:DeployRaffle \
     --fork-url $SEPOLIA_RPC_URL \
     --broadcast \
     --account <ACCOUNT_NAME>
   ```
   - **`<ACCOUNT_NAME>`**: The wallet name you created using `cast wallet import --interactive`.

2. Make sure your wallet has sufficient funds and LINK tokens if required.

---

### Interacting with the Contract

1. Connect your wallet to the target blockchain (local or external).
2. Use the deployed contract's address to interact with it via:
   - Scripts
   - A frontend application
   - Developer tools like [Ethers.js](https://docs.ethers.io/)

---

## Future Enhancements

- Add support for additional testnets and mainnets.
- Improve the frontend for a better user experience.

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
