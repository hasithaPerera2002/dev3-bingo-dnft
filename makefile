# Variables
include .env
export $(shell sed 's/=.*//' .env)

# Targets
install:
	forge install

build:
	forge build

clean:
	forge clean

test:
	forge test -vvv

consoler:
	cast console --rpc-url $(RPC_URL) --private-key $(PRIVATE_KEY)
deploy:
	forge create src/BingoBadge.sol:BingoBadge \
		--rpc-url $(RPC_URL) \
		--private-key $(PRIVATE_KEY) \
		--chain-id 84532 \
		--broadcast
deploy-dry:
	forge script script/Counter.s.sol:Bingo --rpc-url $(RPC_URL) --private-key $(PRIVATE_KEY)

verify:
	forge verify-contract --chain-id 11155111 \
		--num-of-optimizations 200 \
		--watch \
		DEPLOYED_CONTRACT_ADDRESS \
		src/BingoBadge.sol:BingoBadge \
		YOUR_ETHERSCAN_API_KEY