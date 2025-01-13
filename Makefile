CLI_SUFFIX=
ifeq ($(OS),Windows_NT)
    HOST=windows
    CLI_SUFFIX=.exe
else
    HOST_S := $(shell uname -s)
    ifeq ($(HOST_S),Linux)
        HOST=linux
    endif
    ifeq ($(HOST_S),Darwin)
        HOST +=macos
    endif
    HOST_P := $(shell uname -p)
    ifeq ($(HOST_P),x86_64)
        ARCH=amd64
    endif
    ifneq ($(filter %86,$(HOST_P)),)
        ARCH=i386
    endif
    ifneq ($(filter arm%,$(HOST_P)),)
        ARCH=arm
    endif
endif

$(shell mkdir -p ./blockchain/bin)

COMMON_PROPS:=--platform=linux/amd64 --load compiler/src
all: help

lthn-node: ## Start Lethean Chain Node
	[[  -f ./blockchain/bin/letheand$(CLI_SUFFIX) ]] || make lthn-download-$(HOST)-cli
	make mainnet-lthn

lthn-export: ## Export Lethean Chain Node
	./blockchain/bin/lethean-blockchain-export --data-dir=data/lthn --output-file=data/lthn/blockchain.raw

lthn-import: ## Export Lethean Chain Node
	./blockchain/bin/lethean-blockchain-import --data-dir=data/lthn --input-file=data/lthn/blockchain.raw

shutdown: ## Shutdown chain nodes
	@echo "Halting running pids"
	find ./data -type f -name "*.pid" -exec pkill -F "{}" \;
	find ./data -type f -name "*.pid" -exec rm "{}" \;

dev: ## Builds full env
	bash scripts/build-chains.sh

build-itw3-testnet: ## Clone and compile iTw3 in Testnet mode
	bash scripts/build/itw3-testnet.sh

mainnet-lthn: ## Run lethean Blockchain Node
	./blockchain/bin/letheand --confirm-external-bind --detach --rpc-bind-ip=0.0.0.0 --p2p-bind-ip=0.0.0.0 --data-dir=data/lthn --pidfile=data/lthn/letheand.pid

mainnet-wrkz: # Run WrkzCoin Node
	./blockchain/bin/Wrkzd --confirm-external-bind --data-dir=data/wrkz

start-itw3-testnet: ## Start iTw3 Testnet
	./blockchain/bin/itw3d --confirm-external-bind --testnet --detach --rpc-bind-ip=0.0.0.0 --p2p-bind-ip=0.0.0.0 --data-dir=data/itw3/testnet --pidfile=data/itw3/itw3d-testnet.pid

start-lthn-testnet: ## Start Lethean Testnet
	./blockchain/bin/letheand --confirm-external-bind --testnet --detach --rpc-bind-ip=0.0.0.0 --p2p-bind-ip=0.0.0.0 --data-dir=data/lthn/testnet --pidfile=data/lthn/letheand-testnet.pid

start-wrkz-testnet: # Start WrkzCoin Testnet
	./blockchain/bin/Wrkzd --confirm-external-bind --testnet --data-dir=data/wrkz/testnet

lthn-download-windows-cli: ## Download Windows CLI
	[ -f ./blockchain/bin/letheand.exe ] || mkdir -p build/cli && wget https://github.com/letheanVPN/blockchain-iz/releases/latest/download/windows.tar && tar -xvf windows.tar -C ./blockchain/bin && rm windows.tar;

lthn-download-linux-cli:  ## Download Linux CLI
	[ -f ./blockchain/bin/letheand ] || mkdir -p build/cli && wget https://github.com/letheanVPN/blockchain-iz/releases/latest/download/linux.tar && tar -xvf linux.tar -C  ./blockchain/bin && rm linux.tar;

lthn-download-macos-cli:  ## Download macOS CLI
	[ -f ./blockchain/bin/letheand ] || mkdir -p blockchain/bin && wget https://github.com/letheanVPN/blockchain-iz/releases/latest/download/lethean-cli-macos.zip && unzip -d ./blockchain/bin lethean-cli-macos.zip && rm lethean-cli-macos.zip;

wallet-itw3-testnet: ## Open itw3-wallet-cli --testnet
	[ -d ./wallets ] || mkdir -p wallets && cd wallets &&  ../blockchain/bin/itw3-wallet-cli --testnet

wallet-lthn-testnet: ## Open lethean-wallet-cli --testnet
	[ -d ./wallets ] || mkdir -p wallets && cd wallets &&  ../blockchain/bin/lethean-wallet-cli --testnet

wallet-itw3: ## Open itw3-wallet-cli --testnet
	[ -d ./wallets ] || mkdir -p wallets && cd wallets &&  ../blockchain/bin/itw3-wallet-cli

wallet-lthn: ## Open lethean-wallet-cli --testnet
	[ -d ./wallets ] || mkdir -p wallets && cd wallets &&  ../blockchain/bin/lethean-wallet-cli


clean: ## Docker System Prune
	docker system prune --all

help: ## Show this help
	@egrep -h '\s##\s' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m make %-30s\033[0m %s\n", $$1, $$2}'