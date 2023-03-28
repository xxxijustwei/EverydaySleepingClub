import { ethers, network } from "hardhat";
import { CONTRACT_ADDRESS } from "../../contract-address";

async function main() {
    const facet = await ethers.getContractAt("AdminFacet", CONTRACT_ADDRESS[network.name]["Diamond"]);

    console.log("🚧 setCurrency");
    const tx1 = await facet.setCurrency(CONTRACT_ADDRESS[network.name]["USDT"]);
    await tx1.wait();

    console.log("🚧 setRandomizer");
    const tx2 = await facet.setRandomizer(CONTRACT_ADDRESS[network.name]["VRF"]);
    await tx2.wait();

    console.log("🚧 setVoucher");
    const tx3 = await facet.setVoucher(CONTRACT_ADDRESS[network.name]["Voucher"]);
    await tx3.wait();

    console.log("Done!");
}