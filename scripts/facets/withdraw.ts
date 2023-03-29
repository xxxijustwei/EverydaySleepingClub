import { ethers, network } from "hardhat"
import { CONTRACT_ADDRESS } from "../../contract-address"
import Randomizer from "../abi/randomizer.json"

async function main() {
    const accounts = await ethers.getSigners()
    const randomizer = new ethers.Contract(CONTRACT_ADDRESS[network.name]["VRF"], Randomizer.abi, accounts[0])
    const [v1, v2] = await randomizer.clientBalanceOf(CONTRACT_ADDRESS[network.name]["Diamond"])
    console.log(`client balance: ${ethers.utils.formatUnits(v1, 18)}`)
    
    const facet = await ethers.getContractAt("AdminFacet", CONTRACT_ADDRESS[network.name]["Diamond"])
    const tx = await facet.randomizerWithdraw(accounts[0].address, v1)
    await tx.wait()
    console.log(`withdraw done!`)
}

main()