import { task, types } from "hardhat/config";
import { CONTRACT_ADDRESS } from "../contract-address";

task("faucet-mock-usdt", "claim usdt to account")
    .addOptionalParam("amount", "usdt amount", 10000000, types.int)
    .setAction(async (args) => {

        // @ts-ignore
        console.log(`🌐 Claim mock usdt on ${network.name}`);

        console.log(`\n💻 Compiling contract...\n`);
        // @ts-ignore
        await run("compile");


        // @ts-ignore
        const mockUsdtContract = await ethers.getContractAt("MockUSDT", CONTRACT_ADDRESS[network.name]["USDT"]);
        const decimals = await mockUsdtContract.decimals();
        // @ts-ignore
        const accounts = await ethers.getSigners();

        console.log(`\n🚰 Claiming...\n`)
        for (const signer of accounts) {
            // @ts-ignore
            const tx = await mockUsdtContract.connect(signer).faucet(ethers.BigNumber.from(10).pow(decimals).mul(args.amount));
            await tx.wait();

            console.log(`✔️ ${signer.address} claim successed!`);
        }
    })