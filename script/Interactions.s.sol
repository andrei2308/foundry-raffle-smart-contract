//SPDX License Identifier: MIT
pragma solidity ^0.8.19;

import {Script, console2} from "forge-std/Script.sol";
import {HelperConfig, CodeConstants} from "script/HelperConfig.s.sol";
import {VRFCoordinatorV2_5Mock} from "@chainlink/contracts/src/v0.8/vrf/mocks/VRFCoordinatorV2_5Mock.sol";
import {LinkToken} from "test/unit/mocks/LinkToken.sol";
import {DevOpsTools} from "lib/foundry-devops/src/DevOpsTools.sol";

contract CreateSubscription is Script {
    function createSubscriptionUsingConfig() public returns (uint256, address) {
        // Create a new subscription
        HelperConfig helperConfig = new HelperConfig();
        address vrfCoordinator = helperConfig
            .getConfigByChainId(block.chainid)
            .vrfCoordinator;
        address account = helperConfig
            .getConfigByChainId(block.chainid)
            .account;
        return createSubscription(vrfCoordinator, account);
    }

    function createSubscription(
        address vrfCoordinator,
        address account
    ) public returns (uint256, address) {
        console2.log("Creating subscription on chain Id: ", block.chainid);
        vm.startBroadcast(account);
        uint256 subId = VRFCoordinatorV2_5Mock(vrfCoordinator)
            .createSubscription();
        vm.stopBroadcast();
        console2.log("Your subscription Id is: ", subId);
        console2.log(
            "Please update your subscription Id in the HelperConfig contract"
        );
        console2.log("SubOwner:", account);
        return (subId, vrfCoordinator);
    }

    function run() public returns (uint256, address) {
        return createSubscriptionUsingConfig();
    }
}

contract FundSubscription is Script, CodeConstants {
    uint256 public constant FUND_AMOUNT = 3 ether;

    function fundSubscriptionUsingConfig() public {
        HelperConfig helperConfig = new HelperConfig();
        address vrfCoordinator = helperConfig.getConfig().vrfCoordinator;
        uint256 subscriptionId = helperConfig.getConfig().subscriptionId;
        address linkToken = helperConfig.getConfig().link;
        address account = helperConfig.getConfig().account;
        if (subscriptionId == 0) {
            CreateSubscription createSubscription = new CreateSubscription();
            (uint256 updatedSubId, address updatedVRF) = createSubscription
                .run();
            subscriptionId = updatedSubId;
            vrfCoordinator = updatedVRF;
            console2.log("Updated subscription Id: ", subscriptionId);
        }
        fundSubscription(vrfCoordinator, subscriptionId, linkToken, account);
    }

    function fundSubscription(
        address vrfCoordinator,
        uint256 subscriptionId,
        address linkToken,
        address account
    ) public {
        console2.log("Funding subscription", subscriptionId);
        console2.log("Using vrfCoordinator: ", vrfCoordinator);
        console2.log("On chainID: ", block.chainid);
        if (block.chainid == LOCAL_CHAIN_ID) {
            vm.startBroadcast(account);
            VRFCoordinatorV2_5Mock(vrfCoordinator).fundSubscription(
                subscriptionId,
                FUND_AMOUNT * 100
            );
            vm.stopBroadcast();
        } else {
            vm.startBroadcast(account);
            require(
                LinkToken(linkToken).balanceOf(account) >= FUND_AMOUNT,
                "Insufficient LINK balance"
            );
            LinkToken(linkToken).transferAndCall(
                vrfCoordinator,
                FUND_AMOUNT,
                abi.encode(subscriptionId)
            );
            vm.stopBroadcast();
        }
    }

    function run() public {
        fundSubscriptionUsingConfig();
    }

    function getFundAmount() public pure returns (uint256) {
        return FUND_AMOUNT * 100;
    }
}

contract AddConsumer is Script {
    function addConsumerUsingConfig(address mostRecentlyDeployed) public {
        HelperConfig helperConfig = new HelperConfig();
        uint256 subId = helperConfig.getConfig().subscriptionId;
        address vrfCoordinator = helperConfig.getConfig().vrfCoordinator;
        address account = helperConfig.getConfig().account;
        addConsumer(mostRecentlyDeployed, vrfCoordinator, subId, account);
    }

    function addConsumer(
        address contractToAddtoVrf,
        address vrfCoordinator,
        uint256 subId,
        address account
    ) public {
        console2.log("Adding consumer to VRF Coordinator: ", vrfCoordinator);
        console2.log("Using subscription Id: ", subId);
        console2.log("On chainID: ", block.chainid);
        console2.log("Who adds consumer: ", account);
        vm.startBroadcast(account);
        VRFCoordinatorV2_5Mock(vrfCoordinator).addConsumer(
            subId,
            contractToAddtoVrf
        );
        vm.stopBroadcast();
    }

    function run() external {
        address mostRecentlyDeployed = DevOpsTools.get_most_recent_deployment(
            "Raffle",
            block.chainid
        );
        addConsumerUsingConfig(mostRecentlyDeployed);
    }
}
