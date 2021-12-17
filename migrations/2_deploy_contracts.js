const NFT = artifacts.require("./NFT");

module.exports = async function (deployer) {
    const accounts = await web3.eth.getAccounts()

    const IPFS_IMAGE_METADATA_URI = `ipfs://QmQdPYTY8yArgVmMJK319e75rsi91bwtUF5JsSF9CLnEYe/`

    await deployer.deploy(
        NFT,
        "Famous Paintings",
        "PAINT",
        IPFS_IMAGE_METADATA_URI,
        25, // 25%
        accounts[1] // Artist
    )
};