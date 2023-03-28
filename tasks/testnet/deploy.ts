// @ts-nocheck
import fs from "fs";
// import { ethers, network } from "hardhat";
import { task } from "hardhat/config"
import keccak256 from "keccak256";
import MerkleTree from "merkletreejs";
import { CONTRACT_ADDRESS } from "../../contract-address";

task("testnet-deploy", "deploy contract to local")
    .setAction(async (args) => {

        let address: {[key: string]: string} = {};

        if (network.name != "testnet") {
            console.log(`🌐 Error network: ${network.name}`);
            return;
        }

        console.log(`🌐 Network: ${network.name}`);

        console.log(`\n💻 Compiling contract...\n`);
        await run("compile");

        const usdtContract = await ethers.getContractAt("MockUSDT", CONTRACT_ADDRESS["testnet"]["USDT"]);

        console.log(`\n🚧 Deploying sft contract...`);
        const sftFactory = await ethers.getContractFactory("I3abyDogClub");
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

        console.log(`\n🚧 Deploying samoyed svg library...`);
        const samoyedFactory = await ethers.getContractFactory("Samoyed");
        const samoyedLib = await samoyedFactory.deploy();
        await samoyedLib.deployTransaction.wait();
        console.log(`✔️ Done!`);

        console.log(`\n🚧 Deploying slot descriptor contract...`);
        const samoyedDescFactory = await ethers.getContractFactory("SamoyedDescriptor", {
            libraries: {
                Samoyed: samoyedLib.address
            }
        });
        const samoyedContract = await samoyedDescFactory.deploy();
        await samoyedContract.deployTransaction.wait();
        console.log(`✔️ Address: ${samoyedContract.address}`);
        address["Samoyed"] = samoyedContract.address;

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
        const lotteryFactory = await ethers.getContractFactory("USDTLottery");
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
        const setVRF = await lotteryContract.setRandomizer(CONTRACT_ADDRESS["testnet"]["VRF"]);
        await setVRF.wait();
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
            samoyedContract.address,
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

        save(address);
    });

function save(address: { [key: string]: string }) {
    const path = "./tasks/testnet/.address.json";
    fs.writeFileSync(
        path,
        JSON.stringify(address, null, "\t")
    )
}