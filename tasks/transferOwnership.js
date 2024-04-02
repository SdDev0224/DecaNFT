module.exports = async function (taskArgs, hre) {

    let onft = hre.network.name == "ethereum" ? await ethers.getContract("DecaProxyNFT") : await ethers.getContract("DecaNFT")

    let multisigs = {
        "ethereum":  "0xD467121EFEaE6Bd4F016eF7D1F4d4f37B0d91cA9" ,
        "bsc":       "0x1846EdA729AE266B721eDAe04F0df0d37A2581e9" ,
        "polygon":   "0xf9B8Bb8421C9989947cC15ab9CC1E32370F964dD" ,
        "arbitrum":  "0x40B9d818B6f76594036b310EfaDd8548c90a1978" ,
        "avalanche": "0xf54c9A0E44a5F5aFd27C7aC8a176A843b9114F1d" ,
        "optimism":  "0xf54c9A0E44a5F5aFd27C7aC8a176A843b9114F1d" ,
        "fantom":    "0xf54c9A0E44a5F5aFd27C7aC8a176A843b9114F1d" ,
    }

    let signers = await ethers.getSigners()
    console.log(`current local signer/deployer: ${signers[0].address}`)
    console.log(`onft: `, onft.address)


    let newOwner = multisigs[hre.network.name]
    let codeAt = await ethers.provider.getCode(newOwner)
    console.log(codeAt)
    console.log("Network: ", hre.network.name , "New Owner: ", newOwner)

    if (codeAt == "0x") {
        throw "Invalid multisig address"
    }

    let tx = await (await onft.transferOwnership(newOwner)).wait()
    console.log(` tx: ${tx.transactionHash}`)
}
