
require("@nomicfoundation/hardhat-toolbox");
require("dotenv").config();
require("hardhat-deploy");

const SEPOLIA_RPC = process.env.SEPOLIA_RPC;
const PRIVATE_KEY = process.env.PRIVATE_KEY;
const API_KEY = process.env.API_KEY;

module.exports = {
 solidity: "0.8.19",
 defaultNetwork: "hardhat",
 networks: {
  sepolia: {
   url: SEPOLIA_RPC,
   accounts: [
    PRIVATE_KEY
],
chainId: 11155111,
blockConfirmations: 6,
  },
 },

 etherscan: {
  // Your API key for Etherscan
  // Obtain one at https://etherscan.io/
  apiKey: API_KEY,
 },
 namedAccounts: {
    deployer: {
        default: 0,
        11155111: 0,
    }
 }
};


