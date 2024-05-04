#!/bin/bash

# Fork block number is for Base Testnet

source .env
echo "Running tests"
forge test --fork-url $(grep ETH_RPC_URL .env | cut -d '=' -f2) --fork-block-number 9515700 -vvv --via-ir