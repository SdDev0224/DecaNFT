module.exports = async function (taskArgs, hre) {
    const payload = "0x000000000000000000000000000000000000000000000000000000000000004000000000000000000000000000000000000000000000000000000000000000800000000000000000000000000000000000000000000000000000000000000014E021FCD439DEF391ED34EE5A41E285B16BD4E21000000000000000000000000000000000000000000000000000000000000000000000000000000000000000010000000000000000000000000000000000000000000000000000000000004DA3"

    let onft = await ethers.getContract("DecaNFT")

    try {
        let tx = await (
            await onft.clearCredits(payload)
        ).wait()
        console.log(` tx: ${tx.transactionHash}`)
    } catch (e) {
        if (e.error?.message.includes("Message sender must own the OmnichainNFT.")) {
            console.log("*Message sender must own the OmnichainNFT.*")
        } else if (e.error?.message.includes("This chain is not a trusted source source.")) {
            console.log("*This chain is not a trusted source source.*")
        } else {
            console.log(e)
        }
    }
}