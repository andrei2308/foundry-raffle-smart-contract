// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import {Script, console2} from "forge-std/Script.sol";
import {VRFCoordinatorV2_5Mock} from "@chainlink/contracts/src/v0.8/vrf/mocks/VRFCoordinatorV2_5Mock.sol";
import {LinkToken} from "test/mocks/LinkToken.sol";

/**
 * @title CodeConstants contract
 * @author Chitoiu Andrei
 * @notice This is an abstract contract meant to hold values for different CodeConstants
 */
abstract contract CodeConstants {
    /*VRF Mock Values*/
    uint96 public MOCK_BASE_FEE = 0.25 ether;
    uint96 public MOCK_GAS_PRICE = 1e9;
    //Link/ETH price
    int256 public MOCK_WEI_PER_UNIT_LINK = 4e15;

    uint256 public constant ETH_SEPOLIA_CHAIN_ID = 11155111;
    uint256 public constant LOCAL_CHAIN_ID = 31337;
}

/**
 * @title HelperConfig contract
 * @author Chitoiu Andrei
 * @notice This contract dinamically handles the global configuration depending on the chain we are deploying on
 * @notice It it configuring the VRF coordinator contract for Sepolia testnet and local chain testing space
 * @notice For local testing it uses a VRFCoordinatorMock and a Link token mock so we can fund the subscription
 */
contract HelperConfig is CodeConstants, Script {
    //** Errors */
    error HelperConfig_InvalidChainId();

    //** Types */
    /**
     * @dev This struct contains all the necessary variables needed to instantiate a VRFConsumer
     * @param entranceFee - defines the entrance fee to enter the raffle
     * @param interval - defines the interval at which time the consumer's performUpkeep will be called by the Chainlink nodes
     * @param vrfCoordinator - the VRFCoordinator contract address. This is the contract that will call the consumer's fulfillRandomWords function
     * @param gasLane - the keyHash representing the gas lane through which our calls are happening, depending on the amount of gas we are willing to pay
     * @param callbackGasLimit - the gas limit we are willing to pay when the VRFCoordinator contract calls our fulfillRandomWords function in the consumer contract
     * @param subscriptionId - the id of the subscription defining the subscription we made to the VRFCoordinator
     * @param link - the address of the Chainlink Link token depending on the chain we are working on
     * @param account - the address of the deployer's account
     */
    struct NetworkConfig {
        uint256 entranceFee;
        uint256 interval;
        address vrfCoordinator;
        bytes32 gasLane;
        uint32 callbackGasLimit;
        uint256 subscriptionId;
        address link;
        address account;
    }
    //** State variables */

    address deployer;
    NetworkConfig public localNetworkConfig;
    mapping(uint256 chainId => NetworkConfig) public networkConfigs;

    //** Functions */
    constructor() {
        networkConfigs[ETH_SEPOLIA_CHAIN_ID] = getSepoliaEthConfig();
    }

    function setConfig(uint256 chainId, NetworkConfig memory config) public {
        networkConfigs[chainId] = config;
    }

    /**
     * @dev This is a function that dinamically handles chain configuration.
     * It currently supports local chain configuration and Sepolia testnet chain configuration
     */
    function getConfigByChainId(uint256 chainId) public returns (NetworkConfig memory) {
        if (networkConfigs[chainId].vrfCoordinator != address(0)) {
            return networkConfigs[chainId];
        } else if (chainId == LOCAL_CHAIN_ID) {
            return getOrCreateAnvilConfig();
        } else {
            revert HelperConfig_InvalidChainId();
        }
    }

    function getSepoliaEthConfig() public pure returns (NetworkConfig memory) {
        return NetworkConfig({
            entranceFee: 0.01 ether,
            interval: 30, //30 seconds
            vrfCoordinator: 0x9DdfaCa8183c41ad55329BdeeD9F6A8d53168B1B,
            gasLane: 0x787d74caea10b2b357790d5b5247c2f63d1d91572a9846f780606e4d953677ae,
            callbackGasLimit: 500000,
            subscriptionId: 92929868081786283001051859072688436333659780913164620031290002461021448262939,
            link: 0x779877A7B0D9E8603169DdbD7836e478b4624789,
            account: 0x95fd8bdd071f25a1baE9086b6f95Eeda9c3EBB78
        });
    }

    function getConfig() public returns (NetworkConfig memory) {
        return getConfigByChainId(block.chainid);
    }

    /**
     * @dev This function handles the configuration for a local chain.
     * It deploys a mock VRFCoordinator and a LinkToken used to fund our subscription
     */
    function getOrCreateAnvilConfig() public returns (NetworkConfig memory) {
        if (localNetworkConfig.vrfCoordinator != address(0)) {
            return localNetworkConfig;
        }
        //Deploy mocks
        vm.startBroadcast();
        VRFCoordinatorV2_5Mock vrfCoordinator =
            new VRFCoordinatorV2_5Mock(MOCK_BASE_FEE, MOCK_GAS_PRICE, MOCK_WEI_PER_UNIT_LINK);
        LinkToken link = new LinkToken();
        vm.stopBroadcast();
        localNetworkConfig = NetworkConfig({
            entranceFee: 0.01 ether,
            interval: 30, //30 seconds
            vrfCoordinator: address(vrfCoordinator),
            gasLane: 0x787d74caea10b2b357790d5b5247c2f63d1d91572a9846f780606e4d953677ae,
            callbackGasLimit: 500000,
            subscriptionId: 0,
            link: address(link),
            account: deployer
        });
        vm.deal(localNetworkConfig.account, 100 ether);
        return localNetworkConfig;
    }

    function setDeployer(address _deployer) public {
        deployer = _deployer;
    }
}
