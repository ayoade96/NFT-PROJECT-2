const { network } = require("hardhat");
const { verify } = require("../utils/verify");
require("dotenv").config();

module.exports = async({ getNamedAccounts, deployments }) => {
    const { deployer } = await getNamedAccounts()
    const { deploy } = deployments

    // deploying our contract 
    const NFTContract = await deploy("DambazDev",{
        from: deployer,
        args: [],
        log: true,
        waitConfirmations: network.config.blockConfirmations,
    })

    // verify contract
    const API_KEY = process.env.API_KEY;
    if(network.config.chainId !== 31337 && API_KEY) {
      await verify(
        NFTContract.address,
        [],
        "contracts/NftContract.sol:DambazDev"
      )
    }

}

module.exports.tag = ["all", "nft"]