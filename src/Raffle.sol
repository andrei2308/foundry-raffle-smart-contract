//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import {VRFConsumerBaseV2Plus} from "@chainlink/contracts/src/v0.8/vrf/dev/VRFConsumerBaseV2Plus.sol";
import {VRFV2PlusClient} from "@chainlink/contracts/src/v0.8/vrf/dev/libraries/VRFV2PlusClient.sol";
import {console} from "forge-std/console.sol";
import {AutomationCompatibleInterface} from "@chainlink/contracts/src/v0.8/interfaces/AutomationCompatibleInterface.sol";

/**
 * @title Raffle contract
 * @author Chitoiu Andrei-Victor
 * @notice This contract is used to create a raffle
 * @dev Implements Chainlink VRFv2.5
 */
contract Raffle is VRFConsumerBaseV2Plus, AutomationCompatibleInterface {
    //** Errors */
    error Raffle_SendMoreToEnterRaffle();
    error Raffle_TransferFailed();
    error Raffle_RaffleNotOpen();
    error Raffle_UpkeepNotNeeded(uint256 balance, uint256 playersLength, uint256 state);
    //*Type declarations */

    enum RaffleState {
        OPEN, //0
        CALCULATING_WINNER //1

    }
    //** State variables */

    uint256 private immutable i_entranceFee;
    address payable[] private s_players;
    //@dev the duration of each lottery in seconds
    uint256 immutable i_interval;
    uint256 private s_lastTimestamp;
    bytes32 private immutable i_keyHash;
    uint256 private immutable i_subscriptionId;
    uint16 private constant REQUEST_CONFIRMATONS = 1;
    uint32 private immutable i_callbackGasLimit;
    uint32 private constant NUM_WORDS = 1;
    address private s_recentWinner;
    RaffleState private s_raffleState;
    address private immutable i_deployer;
    //*Events */

    event RaffleEntered(address indexed player);
    event WinnerPicked(address indexed winner);
    event RequestedRaffleWinner(uint256 indexed requestId);

    //**Functions */
    constructor(
        uint256 entranceFee,
        uint256 interval,
        address vrfCoordinator,
        bytes32 gasLane,
        uint256 subscriptionId,
        uint32 callbackGasLimit,
        address deployer
    ) VRFConsumerBaseV2Plus(vrfCoordinator) {
        i_entranceFee = entranceFee;
        i_interval = interval;
        s_lastTimestamp = block.timestamp;
        i_keyHash = gasLane;
        i_subscriptionId = subscriptionId;
        i_callbackGasLimit = callbackGasLimit;
        s_raffleState = RaffleState.OPEN;
        i_deployer = deployer;
    }

    function enterRaffle() external payable {
        //require(msg.value >= i_entranceFee, "Not enoungh ETH sent !"); -not gas efficient
        if (msg.value < i_entranceFee) {
            revert Raffle_SendMoreToEnterRaffle();
        }
        if (s_raffleState == RaffleState.CALCULATING_WINNER) {
            revert Raffle_RaffleNotOpen();
        }
        s_players.push(payable(msg.sender));
        emit RaffleEntered(msg.sender);
    }

    /**
     * @dev This is the funtion that the Chainlink nodes will call to see
     * if the lottery is ready to have a winner picked.
     * The following should be true in order for upkeepNeeded to be true:
     * 1. The time interval has passed between raffle runs.
     * 2. The lottery is open.
     * 3. The contract hash ETH.
     * 4. Implicitly, your subscription is funded.
     * @param - ignored
     * @return upkeepNeeded - a boolean value that indicates if the contract needs upkeep
     * @return - ignored
     */
    function checkUpkeep(bytes memory /*checkData*/ )
        public
        view
        override
        returns (bool upkeepNeeded, bytes memory /*performData*/ )
    {
        bool timeHasPassed = block.timestamp - s_lastTimestamp >= i_interval;
        bool isOpen = s_raffleState == RaffleState.OPEN;
        bool hasBalance = address(this).balance > 0;
        bool hasPlayers = s_players.length > 0;
        upkeepNeeded = timeHasPassed && isOpen && hasBalance && hasPlayers;
        return (upkeepNeeded, "");
    }

    /**
     * @dev If the checkUpKeep fucnction returns true then this function will send a request to the VRF to generate a random number
     * @param - ignored
     * @notice If the checkUpKeep is true, then it means that a winner could be picked from @param s_players
     * @notice The contract state will be set to CALCULATING_WINNER so that no more players can enter the raffle
     * @notice We will request a random number from the VRF contract
     * @notice We will emit the RequestedRaffleWinner event with the requestId
     */
    function performUpkeep(bytes calldata /* performData */ ) external override {
        (bool upkeepNeeded,) = checkUpkeep("");
        if (!upkeepNeeded) {
            revert Raffle_UpkeepNotNeeded(address(this).balance, s_players.length, uint256(s_raffleState));
        }
        s_raffleState = RaffleState.CALCULATING_WINNER;
        VRFV2PlusClient.RandomWordsRequest memory request = VRFV2PlusClient.RandomWordsRequest({
            keyHash: i_keyHash,
            subId: i_subscriptionId,
            requestConfirmations: 3,
            callbackGasLimit: i_callbackGasLimit,
            numWords: NUM_WORDS,
            extraArgs: VRFV2PlusClient._argsToBytes(VRFV2PlusClient.ExtraArgsV1({nativePayment: false}))
        });
        uint256 requestId = s_vrfCoordinator.requestRandomWords(request);
        emit RequestedRaffleWinner(requestId);
    }

    /**
     * @dev Once the VRF contract generated a random number, it will call this function with the random number as the parameter
     * @param - ignored
     * @param randomWords - the random number (or numbers if requested more numbers) generated by the VRF contract
     * @notice The random number is used to randomly select a winner from @param s_players which is an array of addresses
     * of the players that entered the raffle
     * @notice The winner will immediately receive the balance of the contract
     * @notice @param s_players will be reset to an empty array
     * @notice @param s_raffleState will be set to OPEN
     * @notice @param s_lastTimestamp will be set to the current block.timestamp
     * @notice The winner will be emitted in the WinnerPicked event
     */
    function fulfillRandomWords(
        uint256,
        /*requestId*/
        uint256[] calldata randomWords
    ) internal override {
        //Checks

        //Effects
        uint256 indexOfWinner = randomWords[0] % s_players.length;
        address payable recentWinner = s_players[indexOfWinner];
        s_recentWinner = recentWinner;
        s_raffleState = RaffleState.OPEN;
        s_players = new address payable[](0);
        s_lastTimestamp = block.timestamp;
        emit WinnerPicked(recentWinner);
        //Interactions
        (bool succes,) = recentWinner.call{value: address(this).balance}("");
        if (!succes) {
            revert Raffle_TransferFailed();
        }
    }

    //** Getter functions */
    function getEntranceFee() external view returns (uint256) {
        return i_entranceFee;
    }

    function getRaffleState() external view returns (RaffleState) {
        return s_raffleState;
    }

    function getPlayer(uint256 indexOfPlayer) external view returns (address) {
        return s_players[indexOfPlayer];
    }

    function getLastTimestamp() external view returns (uint256) {
        return s_lastTimestamp;
    }

    function getWinner() external view returns (address) {
        return s_recentWinner;
    }

    function getSubscriptionId() external view returns (uint256) {
        return i_subscriptionId;
    }

    function getNUM_WORDS() external pure returns (uint32) {
        return NUM_WORDS;
    }

    function getIntervalOfRaffleWinnerSelection() external view returns (uint256) {
        return i_interval;
    }

    function getRequestConfirmations() external pure returns (uint16) {
        return REQUEST_CONFIRMATONS;
    }
}
