// @ts-nocheck
import fs from "fs";
// import { ethers } from "hardhat";
import { task, types } from "hardhat/config";
import { CONTRACT_ADDRESS } from "../../contract-address";

task("testnet-play", "")
    .addParam("index", "", 0, types.int)
    .addParam("count", "", 1, types.int)
    .setAction(async (args) => {
        const address = get_contract_address();
        const accounts = await ethers.getSigners();
        
        const usdt = await ethers.getContractAt("MockUSDT", CONTRACT_ADDRESS["testnet"]["USDT"]);
        const sft = await ethers.getContractAt("I3abyDogClub", address["SFT"]);

        const index = args.index;
        const count = args.count;
        const decimals = await usdt.decimals();

        const price = ethers.BigNumber.from(10).pow(decimals).mul(count).mul(2);
        const approve = await usdt.connect(accounts[index]).approve(sft.address, price);
        await approve.wait();

        const play = await sft.connect(accounts[index]).play(accounts[index].address, 100, count);
        await play.wait();

        console.log("done!");
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