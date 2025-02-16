// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import {Test} from "forge-std/Test.sol";
import {Raffle} from "src/Raffle.sol";
import {DeployRaffle} from "script/DeployRaffle.s.sol";
import {CreateSubscription, FundSubscription, AddConsumer} from "script/Interactions.s.sol";
import {HelperConfig, CodeConstants} from "script/HelperConfig.s.sol";
import {VRFCoordinatorV2_5Mock} from "@chainlink/contracts/src/v0.8/vrf/mocks/VRFCoordinatorV2_5Mock.sol";
import {console2} from "forge-std/Script.sol";

contract Interactions is Test {
    Raffle raffle;
    address USER = makeAddr("USER");
    uint256 constant STARTING_BALANCE = 10 ether;
    HelperConfig helperConfig;
    uint256 subId;
    address vrfCoordinator;

    event SubscriptionFunded(uint256 indexed subId, uint256 oldBalance, uint256 newBalance);

    function setUp() external {
        DeployRaffle deployRaffle = new DeployRaffle();
        (raffle, helperConfig) = deployRaffle.deployRaffle();
        HelperConfig.NetworkConfig memory config = helperConfig.getConfig();
        vrfCoordinator = config.vrfCoordinator;
        subId = config.subscriptionId;

        vm.deal(USER, STARTING_BALANCE);
    }

    function testUserCanFundSubscriptionInteractions() external {
        uint96 initialBalance = VRFCoordinatorV2_5Mock(vrfCoordinator).s_totalBalance();
        FundSubscription fundSubscription = new FundSubscription();
        fundSubscription.fundSubscription(
            vrfCoordinator, subId, helperConfig.getConfig().link, helperConfig.getConfig().account
        );
        uint96 finalBalance = VRFCoordinatorV2_5Mock(vrfCoordinator).s_totalBalance();
        assertEq(
            finalBalance, initialBalance + fundSubscription.getFundAmount(), "Balance should be increased by 3 ether"
        );
    }
}
