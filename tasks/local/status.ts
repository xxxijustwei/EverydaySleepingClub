// @ts-nocheck
import fs from "fs";
// import { ethers } from "hardhat";
import { task } from "hardhat/config";

task("local-status", "")
    .setAction(async (args) => {
        const address = get_contract_address();
        const accounts = await ethers.getSigners();
        const usdt = await ethers.getContractAt("MockUSDT", address["USDT"]);
        const lottery = await ethers.getContractAt("USDTLotteryTest", address["Lottery"]);
        const sft = await ethers.getContractAt("I3abyDogClubTest", address["SFT"]);

        const usdtDecimals = await usdt.decimals();
        const valueDecimals = await sft.valueDecimals();

        const bonusPool = await lottery.bonusPool();
        const jackPool = await lottery.jackPool();
        const sharesPool = await sft.sharesPool(100);
        const dividendPool = await sft.dividendPool(100);
        const [totalPayin, totalPayout] = await lottery.getGameStatus();
        console.log(`bonusPool: ${ethers.utils.formatUnits(bonusPool, usdtDecimals)}`);
        console.log(`jackPool: ${ethers.utils.formatUnits(jackPool, usdtDecimals)}`);
        console.log(`sharesPool: ${ethers.utils.formatUnits(sharesPool, usdtDecimals)}`);
        console.log(`dividendPool: ${ethers.utils.formatUnits(dividendPool, usdtDecimals)}`);

        const a = ethers.utils.formatUnits(totalPayin, usdtDecimals);
        const b = ethers.utils.formatUnits(totalPayout, usdtDecimals);
        console.log(`totalPayin: ${a}`);
        console.log(`totalPayout: ${b}`);
        const c = (Number(b) / Number(a)) * 100;
        console.log(`totalRate: ${c}%`);

        for (let i = 0; i < 10; i++) {
            const signer = accounts[i];
            const [v1, v2] = await lottery.getUserData(signer.address);
            const tokenId = await sft.getUserFirstTokenIdInSlot(signer.address, 100);
            const balance = await sft["balanceOf(uint256)"](tokenId);
            const pv = await sft.getUserSharesValue(signer.address, 100);
            const dv = await sft.getUserDividendValue(signer.address, 100);
            console.log(`\nuser: ${signer.address}`);
            
            const a1 = ethers.utils.formatUnits(v1, usdtDecimals);
            const a2 = ethers.utils.formatUnits(v2, usdtDecimals);
            const a3 = ethers.utils.formatUnits(pv, usdtDecimals);
            const a4 = ethers.utils.formatUnits(dv, usdtDecimals);

            const a = (Number(a2) / Number(a1)) * 100;
            const b = (Number(a2) + Number(a3) + Number(a4)) / Number(a1) * 100;
            console.log(`expend: ${a1}`);
            console.log(`income: ${a2}`);
            console.log(`rate: ${a}%`);
            console.log(`slot amount: ${ethers.utils.formatUnits(balance, valueDecimals)}`);
            console.log(`shares value: ${a3}`);
            console.log(`dividend value: ${a4}`);
            console.log(`total rate: ${b}%`);
        }
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