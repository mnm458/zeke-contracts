# zeke-contracts

Smart contracts for Zeke - a zero-knowledge proof powered protocol that enables anyone to onramp and offramp in a completely decentralized peer-to-peer manner.

Zeke smart contracts include a Ramp contract which is the single point of contact for users, and handles all the business logic and intricacies of creating, managing, completing and verifying orders. Ramp contract works in conjunction with Manager contracts - OrderManager, TokenManager, UserManager and EscrowManager. The Ramp also integrates with the Verifier contract which validates and verifies our ZK circuit proofs.

## System requirements

- [Forge](https://github.com/foundry-rs/foundry)

## Deployment Instructions

1. Create .env file and enter required parameters as shown in .env.example

2. Compile the contracts - `forge build --via-ir`

3. Run deploy script - `bash script/deploy.sh`

## Commands

Build - `forge build --via-ir`

Deploy - `bash script/deploy.sh`

Test - `bash script/test.sh`

Build and view Documentation - `bash script/serve-docs.sh`

## Partner Integrations

Chainlink Price Feeds
- Validate minimum requested fiat conversion rate for onrampers
- Validate fiat amounts paid by offrampers against the onramper requested amounts

## Deployments

Base Sepolia Testnet
- Ramp: 0x3ef2b76449828df079e29df5bb7eb51a39daf46c
- EscrowManager: 0x7c933BFdA1A5CC3E30C0DB8f1eD8d986D0952E48
- OrderManager: 0xBcDdD7B7E6F90928f422C05d407e3EC4685A6465
- TokenManager: 0x85c76A83f106023BF4e3E8dF3EF92C9547f5172b
- UserManager: 0xe37D8690268BECE377D8bfDd1000BB39193c5AA7
- Verifier: 0xEF7dd30092D812068047109e55DeF88b74522187

Mantle Sepolia Testnet
- Ramp: 0xad47548be7e2e085207062ad03f396bf599f7478
- EscrowManager: 0x8056611A716cbB365220084435cFe6a9a2D6903e
- OrderManager: 0x392b58232DCA2f6ec14EB66d6Fcac1031f3300E5
- TokenManager: 0x1c9E5e0edDad97e47a6c4f6747Aa235EC7424406
- UserManager: 0xd73F259fBB06d158635779961A63C532F24edb72
- Verifier: 0x3Ef2B76449828dF079e29df5Bb7Eb51A39dAf46C