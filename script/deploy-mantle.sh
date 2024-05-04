#!/bin/bash

# Get current environment variables defined in .env
source .env
echo "Running deploy script for Mantle"
# --skip-simulation to fix this issue - https://github.com/foundry-rs/foundry/issues/3487#issuecomment-1277820017
forge script script/Deploy.s.sol:DeployScript --rpc-url $ETH_RPC_URL --skip-simulation --slow --broadcast --verify --verifier blockscout --verifier-url "https://explorer.sepolia.mantle.xyz/api?module=contract&action=verify" -vvvv --via-ir