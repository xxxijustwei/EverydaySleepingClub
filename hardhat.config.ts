import { HardhatUserConfig } from "hardhat/config";
import { config as dotenvConfig } from "dotenv";
import { resolve } from "path";
import "@nomicfoundation/hardhat-toolbox";
import "@openzeppelin/hardhat-upgrades";

import "./tasks";

const dotenvConfigPath: string = process.env.DOTENV_CONFIG_PATH || "./.env";
dotenvConfig({ path: resolve(__dirname, dotenvConfigPath) });

const {
  DEFAULT_NETWORK,
  MNEMONIC,
  ARBITRUM_API_KEY,
  MOONBEAM_API_KEY,
} = process.env;

const accounts = {
  mnemonic: MNEMONIC,
  path: "m/44'/60'/0'/0",
  initialIndex: 0,
  count: 7,
  passphrase: "",
}

const config: HardhatUserConfig = {
  solidity: {
    version: "0.8.17",
    settings: {
      optimizer: {
        enabled: true,
        runs: 200,
      },
    }
  },
  defaultNetwork: DEFAULT_NETWORK,
  networks: {
    moonbaseAlpha: {
      url: 'https://rpc.testnet.moonbeam.network',
      chainId: 1287,
      accounts: accounts
    },
    arbitrumGoerli: {
      url: "https://goerli-rollup.arbitrum.io/rpc",
      chainId: 421613,
      accounts: accounts
    },
    ganache: {
      url: "HTTP://127.0.0.1:8545",
      chainId: 1337,
      accounts: {
        mnemonic: "test test test test test test test test test test test junk",
        path: "m/44'/60'/0'/0",
        initialIndex: 0,
        count: 11,
        passphrase: "",
      }
    }
  },
  etherscan: {
    apiKey: {
      moonbaseAlpha: MOONBEAM_API_KEY!,
      arbitrumGoerli: ARBITRUM_API_KEY!
    }
  }
};

export default config;