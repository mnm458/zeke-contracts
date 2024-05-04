#!/bin/bash

# Get current environment variables defined in .env
source .env
echo "Running deploy script"
forge script script/DeployUSDT.s.sol:DeployUSDTScript --ffi --rpc-url $ETH_RPC_URL --slow --broadcast --verify -vvvv --via-ir