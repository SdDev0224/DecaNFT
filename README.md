<div align="center">
    <img alt="LayerZero" src="resources/LayerZeroLogo.png"/>
</div>

---

# DecaNFT

npx hardhat --network ethereum-goerli deploy --tags DecaNFT
npx hardhat --network ethereum-sepolia deploy --tags DecaNFT

npx hardhat --network ethereum-goerli setTrustedRemote --target-network ethereum-sepolia --contract DecaNFT
npx hardhat --network ethereum-sepolia setTrustedRemote --target-network ethereum-goerli --contract DecaNFT

npx hardhat --network ethereum-goerli setMinDstGas --target-network ethereum-sepolia --contract DecaNFT --packet-type 1 --min-gas 100000
npx hardhat --network ethereum-sepolia setMinDstGas --target-network ethereum-goerli --contract DecaNFT --packet-type 1 --min-gas 100000

npx hardhat --network ethereum-goerli decaNFTMint --contract DecaNFT --token-id 1 --to-address 0x43b1DB0EC2167C8811cA0216A35B3bEfc339689c
npx hardhat --network ethereum-sepolia decaNFTMint --contract DecaNFT --token-id 2 --to-address 0x43b1DB0EC2167C8811cA0216A35B3bEfc339689c 

npx hardhat --network ethereum-goerli decaNFTSend --target-network ethereum-sepolia --token-id 1 --contract DecaNFT
npx hardhat --network ethereum-sepolia decaNFTSend --target-network ethereum-goerli --token-id 2 --contract DecaNFT 