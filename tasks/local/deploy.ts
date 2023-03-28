// @ts-nocheck
import fs from "fs";
// import { ethers } from "hardhat";
import { task } from "hardhat/config"
import keccak256 from "keccak256";
import MerkleTree from "merkletreejs";

task("local-deploy", "deploy contract to local")
    .setAction(async (args) => {

        let address: {[key: string]: string} = {};

        console.log(`🌐 Network: ${network.name}`)

        console.log(`\n💻 Compiling contract...\n`)
        await run("compile");

        console.log(`\n🚧 Deploying usdt contract...`);
        const usdtFactory = await ethers.getContractFactory("MockUSDT");
        const usdtContract = await usdtFactory.deploy();
        await usdtContract.deployTransaction.wait();
        console.log(`✔️ Address: ${usdtContract.address}`);
        address["USDT"] = usdtContract.address;

        console.log(`\n🚧 Deploying sft contract...`);
        const sftFactory = await ethers.getContractFactory("I3abyDogClubTest");
        const sftContract = await sftFactory.deploy();
        await sftContract.deployTransaction.wait();
        console.log(`✔️ Address: ${sftContract.address}`);
        address["SFT"] = sftContract.address;

        console.log(`\n🚧 Deploying sft descriptor contract...`);
        const sftDescriptorFactory = await ethers.getContractFactory("SFTDescriptor");
        const sftDescriptorContract = await sftDescriptorFactory.deploy();
        await sftDescriptorContract.deployTransaction.wait();
        console.log(`✔️ Address: ${sftDescriptorContract.address}`);
        address["SFT_Desc"] = sftDescriptorContract.address;

        console.log(`\n🚧 Deploying slot descriptor contract...`);
        const slot100Factory = await ethers.getContractFactory("SamoyedDescriptor");
        const slot100Contract = await slot100Factory.deploy();
        await slot100Contract.deployTransaction.wait();
        console.log(`✔️ Address: ${slot100Contract.address}`);
        address["Slot100"] = slot100Contract.address;

        console.log(`\n🚧 setSFTDescriptor...`);
        const setSFTDescriptor = await sftContract.setSFTDescriptor(sftDescriptorContract.address);
        await setSFTDescriptor.wait();
        console.log(`✔️ Done!`);

        console.log(`\n🚧 Deploying algorithm contract...`);
        const algorithmFactory = await ethers.getContractFactory("LotteryAlgorithm");
        const algorithmContract = await algorithmFactory.deploy();
        await algorithmContract.deployTransaction.wait();
        console.log(`✔️ Address: ${algorithmContract.address}`);
        address["Algorithm"] = algorithmContract.address;

        console.log(`\n🚧 Deploying lottery contract...`);
        const lotteryFactory = await ethers.getContractFactory("USDTLotteryTest");
        const lotteryContract = await lotteryFactory.deploy();
        await lotteryContract.deployTransaction.wait();
        console.log(`✔️ Address: ${lotteryContract.address}`);
        address["Lottery"] = lotteryContract.address;

        console.log(`\n🚧 Configuration lottery address...`);
        const setCurrency = await lotteryContract.setCurrency(usdtContract.address);
        await setCurrency.wait();
        const setAlgorithm = await lotteryContract.setAlgorithm(algorithmContract.address);
        await setAlgorithm.wait();
        const setERC3525 = await lotteryContract.setERC3525(sftContract.address);
        await setERC3525.wait();
        console.log(`✔️ Done!`);

        console.log(`\n🚧 Claim usdt...`);
        const decimals = await usdtContract.decimals();
        const bonus = ethers.BigNumber.from(10).pow(decimals).mul(100000);
        const jack = ethers.BigNumber.from(10).pow(decimals).mul(10000);
        const funds = ethers.BigNumber.from(10).pow(decimals).mul(1000);
        const faucet = await usdtContract.faucet(bonus.add(jack).add(funds));
        await faucet.wait();
        console.log(`✔️ Done!`);

        console.log(`\n🚧 registerGame...`);
        const approveToSFT = await usdtContract.approve(sftContract.address, funds);
        await approveToSFT.wait();
        const registerGame = await sftContract.registerGame(
            100, 
            lotteryContract.address, 
            slot100Contract.address,
            ethers.BigNumber.from(10).pow(decimals).mul(1000)
        );
        await registerGame.wait();
        console.log(`✔️ Done!`);

        console.log(`\n🚧 Game enable...`);
        const setEnable = await sftContract.setEnable(100, true);
        await setEnable.wait();
        console.log(`✔️ Done!`);
        
        console.log(`\n🚧 Init base pool...`);
        const approveToGame = await usdtContract.approve(lotteryContract.address, bonus.add(jack));
        await approveToGame.wait();
        const put = await lotteryContract.initBasePool(bonus, jack);
        await put.wait();
        console.log(`✔️ Done!`);

        console.log(`\n🚧 Claim airdorp...`);
        const accounts = await ethers.getSigners();
        const members = [
            {
                address: "0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266",
                amount: 10500000000000000n,
            },
            {
                address: "0x70997970C51812dc3A010C7d01b50e0d17dc79C8",
                amount: 6300000000000000n,
            },
            {
                address: "0x3C44CdDdB6a900fa2b585dd299e03d12FA4293BC",
                amount: 4200000000000000n,
            },
        ];
        const leaves = members.map(x => 
            ethers.utils.solidityKeccak256(
                ["address", "uint256"],
                [x.address, x.amount]
            )
        );
        const tree = new MerkleTree(leaves, keccak256, { sort: true });

        for (let i = 0; i < 3; i++) {
            const signer = accounts[i];
            const quantity = members[i]["amount"];

            const leaf = ethers.utils.solidityKeccak256(
                ["address", "uint256"],
                [signer.address, quantity]
            );
            const proof = tree.getHexProof(leaf);

            const tx = await lotteryContract.connect(signer).claimAirdrop(quantity, proof);
            await tx.wait();
            console.log(`${signer.address} done!`);
        }
        console.log(`✔️ Done!`);

        save(address);
    });

function save(address: { [key: string]: string }) {
    const path = "./tasks/local/.address.json";
    fs.writeFileSync(
        path,
        JSON.stringify(address, null, "\t")
    )
}