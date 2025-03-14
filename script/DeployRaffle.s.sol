// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import {Script, console} from "forge-std/Script.sol";
import {Raffle} from "src/Raffle.sol";
import {HelperConfig} from "script/HelperConfig.s.sol";
import {CreateSubscription, FundSubscription, AddConsumer} from "script/Interactions.s.sol";

/**
 * @title DeployRaffle contract
 * @author Chitoiu Andrei
 * @notice This is contract is a script meant to deploy the contracts on a specific chain in order for the application to be used
 */
contract DeployRaffle is Script {
    function run() public {
        deployRaffle();
    }

    /**
     * @dev This function is called once the script is ran.
     * It automatically configures the contracts regarding the chain of deployment.
     * If we are on a local chain it handles creating and funding a subscription.
     * It deploys the raffle contract on the blockchain and automatically adds the contract as a consumer of the VRFCoordinator contract.
     */
    function deployRaffle() public returns (Raffle, HelperConfig) {
        address deployer = msg.sender;
        console.log("Deployer: ", deployer);
        HelperConfig helperConfig = new HelperConfig();
        helperConfig.setDeployer(deployer);
        HelperConfig.NetworkConfig memory config = helperConfig.getConfig();
        if (config.subscriptionId == 0) {
            CreateSubscription createSubscription = new CreateSubscription();
            (config.subscriptionId, config.vrfCoordinator) = createSubscription //110146416707791746939207738026704245955047294542294573815139559467961003768950 , 0x34A1D3fff3958843C43aD80F30b94c5106
                .createSubscription(config.vrfCoordinator, config.account);
            FundSubscription fundSubscription = new FundSubscription();
            fundSubscription.fundSubscription(config.vrfCoordinator, config.subscriptionId, config.link, config.account);
            helperConfig.setConfig(block.chainid, config);
        }
        vm.startBroadcast(config.account);
        Raffle raffle = new Raffle(
            config.entranceFee,
            config.interval,
            config.vrfCoordinator,
            config.gasLane,
            config.subscriptionId,
            config.callbackGasLimit,
            deployer
        );
        vm.stopBroadcast();
        AddConsumer addConsumer = new AddConsumer();
        addConsumer.addConsumer(address(raffle), config.vrfCoordinator, config.subscriptionId, config.account);
        return (raffle, helperConfig);
    }
}
