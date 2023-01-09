import { HardhatUserConfig, task } from "hardhat/config";
import * as tdly from "@tenderly/hardhat-tenderly";
import "@nomiclabs/hardhat-etherscan";
import "@nomiclabs/hardhat-waffle";
import "@nomicfoundation/hardhat-chai-matchers";
import "hardhat-contract-sizer";
import "hardhat-abi-exporter";
import "hardhat-gas-reporter";
import "@typechain/hardhat";
import "solidity-coverage";
import "dotenv/config";
import "xdeployer";

// Turning off the automatic Tenderly verification
tdly.setup({ automaticVerifications: false });

task("accounts", "Prints the list of accounts", async (_, hre) => {
  const accounts = await hre.ethers.getSigners();

  for (const account of accounts) {
    console.log(account.address);
  }
});

task(
  "balances",
  "Prints the list of accounts and their balances",
  async (_, hre) => {
    const accounts = await hre.ethers.getSigners();

    for (const account of accounts) {
      console.log(
        account.address +
          " " +
          (await hre.ethers.provider.getBalance(account.address))
      );
    }
  }
);

const config: HardhatUserConfig = {
  paths: {
    sources: "./contracts/src",
  },
  solidity: {
    version: "0.8.17",
    settings: {
      optimizer: {
        enabled: true,
        runs: 999999,
      },
    },
  },
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
        blockNumber: 7400000,
      },
    },
    mumbai: {
      url: process.env.MUMBAI_ALCHEMY_URL || "",
      accounts:
        process.env.PRIVATE_KEY !== undefined ? [process.env.PRIVATE_KEY] : [],
    },
    goerli: {
      url: process.env.GOERLI_ALCHEMY_URL || "",
      accounts:
        process.env.PRIVATE_KEY !== undefined ? [process.env.PRIVATE_KEY] : [],
    },
  },
  gasReporter: {
    enabled: process.env.REPORT_GAS !== undefined,
    currency: "USD",
  },
  contractSizer: {
    alphaSort: true,
    runOnCompile: true,
    disambiguatePaths: false,
    strict: true,
    only: [],
    except: [],
  },
  abiExporter: {
    path: "./abis",
    runOnCompile: true,
    clear: true,
    flat: false,
    only: [],
    spacing: 2,
    pretty: true,
  },
  etherscan: {
    apiKey: {
      mumbai: process.env.POLYGONSCAN_API_KEY || "",
      goerli: process.env.ETHERSCAN_API_KEY || ""
    }
  }
};

export default config;
