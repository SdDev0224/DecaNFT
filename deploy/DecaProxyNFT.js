const LZ_ENDPOINTS = require("../constants/layerzeroEndpoints.json")
const CHAIN_IDS = require("../constants/chainIds.json")

module.exports = async function ({ deployments, getNamedAccounts }) {
    const { deploy } = deployments
    const { deployer } = await getNamedAccounts()
    console.log(`>>> your address: ${deployer}`)

    const lzEndpointAddress = LZ_ENDPOINTS[hre.network.name]
    console.log(`[${hre.network.name}] Endpoint Address: ${lzEndpointAddress}`)

    await deploy("DecaProxyNFT", {
        from: deployer,
        args: [150000, lzEndpointAddress, "0x524cAB2ec69124574082676e6F654a18df49A048"], // mainnet
        // args: [100000, lzEndpointAddress, "0x8DbA4bf660FF33f1abb8E41915125F068B35c6fD"], // testnet
        log: true,
        waitConfirmations: 3,
        skipIfAlreadyDeployed: true
    })

    let onft = await ethers.getContract("DecaProxyNFT")

    let enabledChains = ["ethereum", "bsc", "arbitrum", "polygon"] // mainnet
    // let enabledChains = ["ethereum-goerli", "arbitrum-goerli"] // testnet

    if (enabledChains.includes(hre.network.name)) {
        // await(await onft.setMinGasToTransferAndStore(150000)).wait()

        for (let n of enabledChains) {
            if (n != hre.network.name) {
                await(await onft.setDstChainIdToTransferGas(CHAIN_IDS[n], 50000)).wait()
                await(await onft.setDstChainIdToBatchLimit(CHAIN_IDS[n], 25)).wait()
                await(await onft.setMinDstGas(CHAIN_IDS[n], 1, 150000)).wait()
            }
        }
    }

    await hre.run("verifyContract", { contract: "DecaProxyNFT" })
}

module.exports.tags = ["DecaProxyNFT"]
