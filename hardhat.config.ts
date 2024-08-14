import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";
import '@openzeppelin/hardhat-upgrades';
require("dotenv").config();

const BSC_RPC_URL = process.env.BSC_RPC_URL as string;
const ACCOUNT_PRIVATE_KEY = process.env.ACCOUNT_PRIVATE_KEY as string;
const ETHERSCAN_API_KEY = process.env.ETHERSCAN_API_KEY as string;

const config: HardhatUserConfig = {
  solidity: "0.8.24",
  defaultNetwork: "bsc_testnet",
  networks: {
    hardhat: {
      
    },
    bsc_testnet: {
      url: BSC_RPC_URL,
      chainId: 97,
      gasPrice: 20000000000,
      accounts: [ACCOUNT_PRIVATE_KEY]
    },
  },
  // @ts-ignore
  etherscan: {
    apiKey: ETHERSCAN_API_KEY,
  }
};

export default config;
