import { HardhatUserConfig, task } from "hardhat/config";
import "@nomiclabs/hardhat-etherscan";
// @ts-ignore
import env from "./env.example.json";
import "@nomiclabs/hardhat-ganache";
import "@nomiclabs/hardhat-waffle";
import * as dotenv from "dotenv";
import "hardhat-gas-reporter";
import "@typechain/hardhat";


dotenv.config();

task("accounts", "Prints the list of accounts",
  async (taskArgs, hre) => {
    const accounts = await hre.ethers.getSigners();
    for (const account of accounts) {
      console.log(account.address);
    }
  });

// You need to export an object to set up your config
// Go to https://hardhat.org/config/ to learn more

const config: HardhatUserConfig = {
  solidity: {
    version: "0.8.9",
    settings: {
      optimizer: {
        enabled: true,
        runs: 200
      }
    }
  },
  networks: {
    bscMain: {
      url: env.BSCMAIN_URL,
      accounts: [env.PRIVATE_KEY]
    },
    bscTest: {
      url: env.BSCTEST_URL,
      accounts: [env.PRIVATE_KEY]
    },
    ganacheLocal: {
      url: env.GANACHE_URL,
      accounts: [env.PRIVATE_KEY]
    }
    // localhost: {
    //   url: "http://127.0.0.1:8545"
    // },
    // hardhat: {
    //   // See its defaults
    // }
  },
  gasReporter: {
    enabled: process.env.REPORT_GAS !== undefined,
    currency: "USD"
  },
  etherscan: {
    apiKey: env.BSCSCAN_API_KEY
  },
  mocha: {
    timeout: 400000
  }
};

export default config;
