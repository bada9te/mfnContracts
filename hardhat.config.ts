import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";
import '@openzeppelin/hardhat-upgrades';
require("dotenv").config();

const ACCOUNT_PRIVATE_KEY = process.env.ACCOUNT_PRIVATE_KEY as string;
const ETHERSCAN_API_KEY = process.env.ETHERSCAN_API_KEY as string;

const config: HardhatUserConfig = {
  solidity: "0.8.24",
  defaultNetwork: "bsc_test",
  networks: {
    hardhat: {},
    bsc: {
      url: "https://bsc-dataseed1.binance.org",
      chainId: 56,
      accounts: [ACCOUNT_PRIVATE_KEY]
    },
    arbitrum: {
      url: "https://arb1.arbitrum.io/rpc",
      chainId: 42161,
      accounts: [ACCOUNT_PRIVATE_KEY]
    },
    avalanche: {
      url: "https://api.avax.network/ext/bc/C/rpc",
      chainId: 43114,
      accounts: [ACCOUNT_PRIVATE_KEY]
    },
    base: {
      url: "https://mainnet.base.org",
      chainId: 8453,
      accounts: [ACCOUNT_PRIVATE_KEY]
    },
    polygon: {
      url: "https://polygon-rpc.com",
      chainId: 137,
      accounts: [ACCOUNT_PRIVATE_KEY]
    },
    
    bsc_test: {
      url: "https://bsc-testnet-rpc.publicnode.com",
      chainId: 97,
      accounts: [ACCOUNT_PRIVATE_KEY]
    },
  },
  etherscan: {
    apiKey: ETHERSCAN_API_KEY,
  },
};

export default config;
