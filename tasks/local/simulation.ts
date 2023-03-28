// @ts-nocheck
import fs from "fs";
// import { ethers } from "hardhat";
import { task, types } from "hardhat/config";
import * as bigintCryptoUtils from "bigint-crypto-utils";


task("local-play", "")
    .addParam("counts", "", 100, types.int)
    .setAction(async (args) => {
        const address = get_contract_address();
        const accounts = await ethers.getSigners();
        const sftContract = await ethers.getContractAt("I3abyDogClubTest", address["SFT"]);
        const usdtContract = await ethers.getContractAt("MockUSDT", address["USDT"]);
        const decimals = await usdtContract.decimals();

        for (let i = 0; i < 10; i++) {
            const signer = accounts[i];
            console.log(`address: ${signer.address}`);
            const amount = ethers.BigNumber.from(10).pow(decimals).mul(100000000);
            const faucet = await usdtContract.connect(signer).faucet(amount);
            await faucet.wait();
            const approve = await usdtContract.connect(signer).approve(sftContract.address, amount);
            await approve.wait(2);

            for (let k = 0; k < args.counts;) {
                try {
                    const tx = await sftContract.connect(signer).play(signer.address, 100, 100, bigintCryptoUtils.randBetween(2n ** 256n));
                    console.log(`${k}. ${tx.hash}`);
                    k++;
                } catch(ignore) {
                    console.log(ignore)
                }
            }
        }

        console.log("done");
    })

function get_contract_address() {
    let address: { [key: string]: string } = {};

    const path = "./tasks/local/.address.json";
    try {
        let data = fs.readFileSync(path, "utf-8");
        let obj = JSON.parse(data);
        for (let key in obj) {
            address[key] = obj[key];
        }
    } catch (ignore) { }

    return address;
}