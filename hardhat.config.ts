import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox-viem";

const config: HardhatUserConfig = {
  solidity: {
    version: "0.8.24",
    settings: {
      viaIR: true,
      optimizer: {
        enabled: true,
        details: {
          yulDetails: {
            optimizerSteps: "u",
          },
        },
      },
    }
  },
  networks: {
    dev: { url: 'http://localhost:8545' },
    base: {
      url: process.env.BASE_URL || '',
      chainId: 8453,
    },
    mantle: {
      url: process.env.MANTLE_URL || '',
      chainId: 5000,
    },
  }
};

export default config;
