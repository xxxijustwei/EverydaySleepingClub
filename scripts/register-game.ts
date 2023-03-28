import { ethers, network } from "hardhat";
import { CONTRACT_ADDRESS } from "../contract-address";

async function main() {
    const voucher = await ethers.getContractAt("EverydaySleepingClub", CONTRACT_ADDRESS[network.name]["Voucher"]);

    console.log(`\n🚧 Claim usdt...`);
    const usdt = await ethers.getContractAt("MockUSDT", CONTRACT_ADDRESS[network.name]["USDT"]);
    const decimals = await usdt.decimals();
    const bonus = ethers.BigNumber.from(10).pow(decimals).mul(100000);
    const jack = ethers.BigNumber.from(10).pow(decimals).mul(10000);
    const funds = ethers.BigNumber.from(10).pow(decimals).mul(1000);
    const faucet = await usdt.faucet(bonus.add(jack).add(funds));
    await faucet.wait();
    console.log(`   Done!`);

    console.log(`\n🚧 registerGame...`);
    const approve = await usdt.approve(voucher.address, funds);
    await approve.wait();
    const registerGame = await voucher.registerGame(
        100,
        CONTRACT_ADDRESS[network.name]["Diamond"],
        ethers.BigNumber.from(10).pow(decimals).mul(1000)
    );
    await registerGame.wait();
    console.log(`   Done!`);

    console.log(`\n🚧 Game enable...`);
    const setEnable = await voucher.setEnable(100, true);
    await setEnable.wait();
    console.log(`   Done!`);
}

main();