// @ts-nocheck
import fs from "fs"
// import { ethers, network } from "hardhat"
import { task, types } from "hardhat/config"
import { CONTRACT_ADDRESS } from "../../contract-address"
import Randomizer from "../../scripts/abi/randomizer.json"

task("testnet-play", "")
    .addParam("index", "", 0, types.int)
    .addParam("times", "", 1, types.int)
    .setAction(async (args) => {
        console.log(`\n🚧 play game...`)
        const address = get_contract_address()
        const accounts = await ethers.getSigners()
        
        const usdt = await ethers.getContractAt("MockUSDT", CONTRACT_ADDRESS[network.name]["USDT"])
        const voucher = await ethers.getContractAt("EverydaySleepingClub", address["Voucher"])

        const index = args.index
        const times = args.times
        const decimals = await usdt.decimals()
        const pay = ethers.BigNumber.from(10).pow(decimals).mul(times).mul(2)
        console.log(`player: ${accounts[index].address}`)
        console.log(`times: ${times}`)
        console.log(`pay: ${ethers.utils.formatUnits(pay, decimals)}`)

        const approve = await usdt.connect(accounts[index]).approve(voucher.address, pay)
        await approve.wait()
        console.log(`usdt approved`)

        const feeData = await ethers.provider.getFeeData()
        const gasLimit = 100000 + times * 3000
        const randomizer = new ethers.Contract(CONTRACT_ADDRESS[network.name]["VRF"], Randomizer.abi, accounts[0])
        const fee = await randomizer.estimateFeeUsingGasPrice(gasLimit, feeData.gasPrice)

        console.log(`play gas limit: ${gasLimit}`)
        console.log(`play fee: ${ethers.utils.formatEther(fee)}`)
        
        const play = await voucher.connect(accounts[index]).play(
            accounts[index].address, 
            100, 
            times, 
            {
                value: fee
            }
        )
        await play.wait()

        console.log("play done!")
    })

function get_contract_address() {
    let address: { [key: string]: string } = {};

    const path = "./tasks/testnet/.address.json";
    try {
        let data = fs.readFileSync(path, "utf-8");
        let obj = JSON.parse(data);
        for (let key in obj) {
            address[key] = obj[key];
        }
    } catch (ignore) { }

    return address;
}