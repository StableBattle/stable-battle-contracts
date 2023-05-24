import { HardhatUserConfig } from "hardhat/config";
import "@nomiclabs/hardhat-etherscan";
import "@nomiclabs/hardhat-waffle";
import "@typechain/hardhat";
import "hardhat-gas-reporter";
import "solidity-coverage";
import "dotenv/config";

const config: HardhatUserConfig = {
  solidity: "0.8.18",
//mocha: { timeout: 100000000 },
  networks: {
    hardhat: {
      /*
      forking: {
        url: process.env.MUMBAI_ALCHEMY_URL || "",
        blockNumber: 26681409,
      },
      */
      forking: {
        url: process.env.GOERLI_ALCHEMY_URL || "",
        blockNumber: 9000000
      }
    },
    mumbai: {
      url: process.env.MUMBAI_ALCHEMY_URL || "",
      accounts:
        process.env.PRIVATE_KEY !== undefined ? [process.env.PRIVATE_KEY] : [],
    },
    goerli: {
      url: process.env.GOERLI_INFURA_URL || "",
      accounts:
        process.env.PRIVATE_KEY !== undefined ? [process.env.PRIVATE_KEY] : [],
    },
  },
  gasReporter: {
    enabled: process.env.REPORT_GAS !== undefined,
    currency: "USD",
  },
  etherscan: {
    apiKey: process.env.ETHERSCAN_API_KEY,
    /*{
      mumbai: process.env.POLYGONSCAN_API_KEY,
      goerli: process.env.ETHERSCAN_API_KEY
    }*/
  }
};

export default config;
