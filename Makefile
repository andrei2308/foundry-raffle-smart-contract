-include .env

.PHONY: all test clean deploy fund help install snapshot format anvil 

DEFAULT_ANVIL_KEY := 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80

help:
	@echo "Usage:"
	@echo "  make deploy [ARGS=...]\n    example: make deploy ARGS=\"--network sepolia\""
	@echo ""
	@echo "  make fund [ARGS=...]\n    example: make deploy ARGS=\"--network sepolia\""

all: clean remove install update build

# Clean the repo
clean  :; forge clean

# Remove modules
remove :; rm -rf .gitmodules && rm -rf .git/modules/* && rm -rf lib && touch .gitmodules && git add . && git commit -m "modules"

install :; forge install cyfrin/foundry-devops@0.2.2 --no-commit && forge install smartcontractkit/chainlink-brownie-contracts@1.1.1 --no-commit && forge install foundry-rs/forge-std@v1.8.2 --no-commit && forge install transmissions11/solmate@v6 --no-commit

# Update Dependencies
update:; forge update

build:; forge build

test :; forge test 

snapshot :; forge snapshot

format :; forge fmt

anvil :; anvil -m 'test test test test test test test test test test test junk' --steps-tracing --block-time 1

NETWORK_ARGS := --rpc-url http://localhost:8545 --private-key $(DEFAULT_ANVIL_KEY) --broadcast

ifeq ($(findstring --network sepolia,$(ARGS)),--network sepolia)
	NETWORK_ARGS := --rpc-url $(SEPOLIA_RPC_URL) --private-key $(PRIVATE_KEY) --broadcast --verify --etherscan-api-key $(ETHERSCAN_API_KEY) -vvvv
endif

deploy:
	@forge script script/DeployRaffle.s.sol:DeployRaffle $(NETWORK_ARGS)

createSubscription:
	@forge script script/Interactions.s.sol:CreateSubscription $(NETWORK_ARGS)

addConsumer:
	@forge script script/Interactions.s.sol:AddConsumer $(NETWORK_ARGS)

fundSubscription:
	@forge script script/Interactions.s.sol:FundSubscription $(NETWORK_ARGS)
deploy-sepolia:
	@forge script script/DeployRaffle.s.sol:DeployRaffle --rpc-url $(SEPOLIA_RPC_URL) --account default --broadcast --verify --etherscan-api-key $(ETHERSCAN_API_KEY) -vvvv
deploy-anvil:
	deploy-anvil:
	@forge script script/DeployRaffle.s.sol:DeployRaffle --broadcast --fork-url http://127.0.0.1:8545 --sender $(SENDER_ADDRESS) --account $(ACCOUNT_NAME)

# For local testing 

# Request upkeep
request:
	@cast send 0xDc64a140Aa3E981100a9becA4E685f962f0cF6C9 \
		"performUpkeep(bytes)" 0x \
		--private-key $(DEFAULT_ANVIL_KEY) \
		--rpc-url http://127.0.0.1:8545

# Fulfill random words
fulfill:
	@cast send 0x5FbDB2315678afecb367f032d93F642f64180aa3 \
		"fulfillRandomWords(uint256,address)" $(REQUEST_ID) \
		0xDc64a140Aa3E981100a9becA4E685f962f0cF6C9 \
		--private-key $(DEFAULT_ANVIL_KEY) \
		--rpc-url http://127.0.0.1:8545
