pragma solidity ^0.8.24;

import { TokenAndFeed } from "../src/Interfaces.sol";

contract ConstructorArgs {
    // chainId => TokenAndFeed[]
    mapping (uint256 => TokenAndFeed[]) public tokenAndFeeds;

    constructor() {
        // Base Sepolia values
        tokenAndFeeds[84532] = new TokenAndFeed[](2);
            // usdc
        tokenAndFeeds[84532][0] = TokenAndFeed({
            token: 0x036CbD53842c5426634e7929541eC2318f3dCF7e,
            feed: 0xd30e2101a97dcbAeBCBC04F14C3f624E67A35165
        });
            // usdt
        tokenAndFeeds[84532][1] = TokenAndFeed({
            // Not a canonical USDT token, just the USDT that appeared in last 20 pages of block explorer ERC20 tokens
            token: 0xF6C7048F2bCF45E414ac727471FbfE367a424e30,
            feed: 0x3ec8593F930EA45ea58c968260e6e9FF53FC934f
        });

        // Base Mainnet values
        tokenAndFeeds[8453] = new TokenAndFeed[](2);
            // usdc
        tokenAndFeeds[8453][0] = TokenAndFeed({
            token: 0x833589fCD6eDb6E08f4c7C32D4f71b54bdA02913,
            feed: 0x7e860098F58bBFC8648a4311b374B1D669a2bc6B
        });
            // usdt
            // No canonical address for USDT found - https://base.l2scan.co/tokens has a USDT with with 104000 total supply which doesn't seem right. Also Base is not listed in https://tether.to/en/supported-protocols/
            // Strange that Chainlink has a USDT feed for Base Mainnet

        // Mantle Mainnet values
        tokenAndFeeds[5000] = new TokenAndFeed[](2);
            // usdc
        tokenAndFeeds[5000][0] = TokenAndFeed({
            token: 0x09Bc4E0D864854c6aFB6eB9A9cdF58aC190D0dF9,
            // Burn address because no Chainlink feed for Mantle
            feed: 0x000000000000000000000000000000000000dEaD
        });
            // usdt
        tokenAndFeeds[5000][1] = TokenAndFeed({
            token: 0x201EBa5CC46D216Ce6DC03F6a759e8E766e956aE,
            // Burn address because no Chainlink feed for Mantle
            feed: 0x000000000000000000000000000000000000dEaD
        });
    }
}