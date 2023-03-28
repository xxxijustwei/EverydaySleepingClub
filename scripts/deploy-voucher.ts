import { ethers, network } from "hardhat";
import { CONTRACT_ADDRESS } from "../contract-address";

async function main() {
    console.log(`\n🚧 Deploying voucher contract...`)
    const voucherFactory = await ethers.getContractFactory("EverydaySleepingClub")
    const voucher = await voucherFactory.deploy()
    await voucher.deployTransaction.wait()
    console.log(`   address: ${voucher.address}`)

    console.log(`\n🚧 Deploying voucher descriptor contract...`);
    const sftDescriptorFactory = await ethers.getContractFactory("SFTDescriptor");
    const sftDescriptor = await sftDescriptorFactory.deploy();
    await sftDescriptor.deployTransaction.wait();
    console.log(`   address: ${sftDescriptor.address}`);

    console.log(`\n🚧 Deploying slot descriptor contract...`);
    const samoyedFactory = await ethers.getContractFactory("Samoyed");
    const samoyedLib = await samoyedFactory.deploy();
    await samoyedLib.deployTransaction.wait();
    const samoyedDescFactory = await ethers.getContractFactory("SamoyedDescriptor", {
        libraries: {
            Samoyed: samoyedLib.address
        }
    });
    const samoyed = await samoyedDescFactory.deploy();
    await samoyed.deployTransaction.wait();
    console.log(`   address: ${samoyed.address}`);

    console.log(`\n🚧 setSFTDescriptor...`);
    const setSFTDescriptor = await voucher.setSFTDescriptor(voucher.address);
    await setSFTDescriptor.wait();
    console.log(`   Done!`);

    console.log(`\n🚧 setSlotDescriptor...`);
    const setSlotDescriptor = await voucher.setSlotDescriptor(100, samoyed.address);
    await setSlotDescriptor.wait();
    console.log(`   Done!`);
}

main();