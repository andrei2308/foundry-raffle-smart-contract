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
    uint96 initialBalance;

    function setUp() external {
        DeployRaffle deployRaffle = new DeployRaffle();
        (raffle, helperConfig) = deployRaffle.deployRaffle();
        vrfCoordinator = helperConfig.getConfig().vrfCoordinator;
        subId = helperConfig.getConfig().subscriptionId;
        initialBalance = VRFCoordinatorV2_5Mock(vrfCoordinator).s_totalBalance();
        vm.deal(USER, STARTING_BALANCE);
    }

    function testUserCanFundSubscriptionInteractions() external {
        FundSubscription fundSubscription = new FundSubscription();
        fundSubscription.fundSubscription(
            vrfCoordinator,
            subId,
            helperConfig.getConfig().link,
            helperConfig.getConfig().account
        );
        uint96 finalBalance = VRFCoordinatorV2_5Mock(vrfCoordinator)
            .s_totalBalance();
        assertEq(
            finalBalance,
            initialBalance + fundSubscription.getFundAmount()
        );
    }
}
