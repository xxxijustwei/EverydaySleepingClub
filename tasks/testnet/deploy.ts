// @ts-nocheck
import fs from "fs";
// import { ethers, network } from "hardhat";
import { task } from "hardhat/config"
import keccak256 from "keccak256"
import MerkleTree from "merkletreejs"
import { CONTRACT_ADDRESS } from "../../contract-address"
import { FacetCutAction, getSelectors } from "../../scripts/libraries/diamond"

task("testnet-deploy", "deploy contract to local")
    .addOptionalParam("verify", "", false, types.boolean)
    .setAction(async (args) => {

        let addresses: { [key: string]: string } = {}

        if (network.name == "hardhat" || network.name == "ganache") {
            console.log(`🌐 Error network: ${network.name}`)
            return
        }

        console.log(`🌐 Network: ${network.name}`)

        console.log(`\n💻 Compiling contract...\n`)
        await run("compile")

        const verify = args.verify;
        const accounts = await ethers.getSigners()
        const usdt = await ethers.getContractAt("MockUSDT", CONTRACT_ADDRESS[network.name]["USDT"])

        // deploy Diamond
        let dUnverified = [];
        console.log(`\n🚧 Deploying diamond...`)
        const owner = accounts[0];
        const DiamondCutFacet = await ethers.getContractFactory('DiamondCutFacet')
        const diamondCutFacet = await DiamondCutFacet.deploy()
        await diamondCutFacet.deployed()
        dUnverified.push(diamondCutFacet.address)
        console.log('   DiamondCutFacet deployed:', diamondCutFacet.address)

        const Diamond = await ethers.getContractFactory('LotteryDiamond')
        const diamond = await Diamond.deploy(owner.address, diamondCutFacet.address)
        await diamond.deployed()
        addresses["LotteryDiamond"] = diamond.address
        console.log('   Diamond deployed:', diamond.address)

        const DiamondInit = await ethers.getContractFactory('DiamondInit')
        const diamondInit = await DiamondInit.deploy()
        await diamondInit.deployed()
        dUnverified.push(diamondInit.address)
        console.log('   DiamondInit deployed:', diamondInit.address)

        const FacetNames = [
            'DiamondLoupeFacet',
            'OwnershipFacet',
            'AdminFacet',
            'AirdropFacet',
            'AlgorithmFacet',
            'GameFacet'
        ]
        const config = {
            intvals: [0, 5, 43, 431, 2946, 11552, 55712, 238045, 1590756, 20448182, 80014532, 177904515],
            rewards: [0, 1, 2, 5, 10, 20, 100, 1000, 10000, 50000, 100000, 500000, 1000000],
            fibonacci: [1, 2, 3, 5, 8, 13, 21, 34, 55, 89, 144, 233, 377, 610, 987, 1597, 2584, 4181, 6765, 10946]
        }
        const cut = []
        for (const FacetName of FacetNames) {
            const Facet = await ethers.getContractFactory(FacetName)
            const facet = await Facet.deploy()
            await facet.deployed()
            dUnverified.push(facet.address);
            console.log(`   ${FacetName} deployed: ${facet.address}`)
            cut.push({
                facetAddress: facet.address,
                action: FacetCutAction.Add,
                functionSelectors: getSelectors(facet)
            })
        }
        const diamondCut = await ethers.getContractAt('IDiamondCut', diamond.address)
        const funcCall = diamondInit.interface.encodeFunctionData("init", [config])
        const cutFacet = await diamondCut.diamondCut(cut, diamondInit.address, funcCall)
        await cutFacet.wait();
        
        console.log(`✔️  Diamond done!`);

        // deploy voucher
        console.log(`\n🚧 Deploying voucher...`);
        const voucherFactory = await ethers.getContractFactory("EverydaySleepingClub");
        const voucher = await voucherFactory.deploy();
        await voucher.deployTransaction.wait();
        console.log(`   EverydaySleepingClub deployed: ${voucher.address}`);
        addresses["Voucher"] = voucher.address;

        const sftDescriptorFactory = await ethers.getContractFactory("SFTDescriptor");
        const sftDescriptor = await sftDescriptorFactory.deploy();
        await sftDescriptor.deployTransaction.wait();
        console.log(`   SFTDescriptor deployed: ${sftDescriptor.address}`);

        const samoyedLibFactory = await ethers.getContractFactory("Samoyed");
        const samoyedLib = await samoyedLibFactory.deploy();
        await samoyedLib.deployTransaction.wait();
        const samoyedDescriptorFactory = await ethers.getContractFactory("SamoyedDescriptor", {
            libraries: {
                Samoyed: samoyedLib.address
            }
        });
        const samoyedDescriptor = await samoyedDescriptorFactory.deploy();
        await samoyedDescriptor.deployTransaction.wait();
        console.log(`   SamoyedDescriptor deployed: ${samoyedDescriptor.address}`);
        console.log(`✔️  Voucher done!`)

        if (verify) {
            console.log(`\n🚧 Verifying contract...`)
            await run("verify:verify", {
                address: diamond.address,
                constructorArguments: [
                    owner.address,
                    diamondCutFacet.address
                ]
            })
            for (const c of dUnverified) {
                await run("verify:verify", {
                    address: c,
                })
            }

            await run("verify:verify", {
                address: voucher.address
            })
            await run("verify:verify", {
                address: sftDescriptor.address
            })
            await run("verify:verify", {
                address: samoyedDescriptor.address,
                libraries: {
                    Samoyed: samoyedLib.address
                }
            })
            console.log(`✔️  Already verified!`)
        }

        save(addresses)

        // config
        console.log(`\n🚧 Config contracts...`)

        const setSFTDescriptor = await voucher.setSFTDescriptor(sftDescriptor.address)
        await setSFTDescriptor.wait()
        console.log(`   Voucher | setSFTDescriptor done!`)

        const setSlotDescriptor = await voucher.setSlotDescriptor(100, samoyedDescriptor.address)
        await setSlotDescriptor.wait()
        console.log(`   Voucher | setSlotDescriptor done!`)

        const adminFacet = await ethers.getContractAt("AdminFacet", diamond.address)

        const setCurrency = await adminFacet.setCurrency(usdt.address)
        await setCurrency.wait()
        console.log(`   Diamond | setCurrency done!`)

        const setRandomizer = await adminFacet.setRandomizer(CONTRACT_ADDRESS[network.name]["VRF"])
        await setRandomizer.wait()
        console.log(`   Diamond | setRandomizer done!`)

        const setVoucher = await adminFacet.setVoucher(voucher.address)
        await setVoucher.wait()
        console.log(`   Diamond | setVoucher done!`)

        const decimals = await usdt.decimals()
        const bonus = ethers.BigNumber.from(10).pow(decimals).mul(100000)
        const jack = ethers.BigNumber.from(10).pow(decimals).mul(10000)
        const funds = ethers.BigNumber.from(10).pow(decimals).mul(1000)
        const faucet = await usdt.faucet(bonus.add(jack).add(funds))
        await faucet.wait()
        console.log(`   USDT | faucet done!`)

        const approveVoucher = await usdt.approve(voucher.address, funds)
        await approveVoucher.wait()
        console.log(`   USDT | approve to voucher!`)

        const registerGame = await voucher.registerGame(
            100,
            diamond.address,
            funds
        )
        await registerGame.wait();
        console.log(`   Voucher |  register game done!`)

        const enableGame = await voucher.setEnable(100, true)
        await enableGame.wait()
        console.log(`   Voucher | enable game!`)

        const approveDiamond = await usdt.approve(diamond.address, bonus.add(jack))
        await approveDiamond.wait()
        console.log(`   USDT | approve to diamond`)

        const initPot = await adminFacet.initPot(bonus, jack)
        await initPot.wait()
        console.log(`   Diamond | init pot done!`)
        console.log(`✔️  Config done!`)

        // airdrop
        console.log(`\n🚧 Claim airdrop...`)
        const airdropFacet = await ethers.getContractAt("AirdropFacet", diamond.address)

        const members = [
            {
                address: "0x3869E25C9F93a9d48D769e000A2bC603f4991a98",
                amount: 10500000000000000n,
            },
            {
                address: "0xB848F28A09943303c89EA5a6b66D45287AD745f9",
                amount: 6300000000000000n,
            },
            {
                address: "0x6a569215be90A55B4c615368fCB13F75d99c8A60",
                amount: 4200000000000000n,
            },
        ]
        const leaves = members.map(x => 
            ethers.utils.solidityKeccak256(
                ["address", "uint256"],
                [x.address, x.amount]
            )
        )
        const tree = new MerkleTree(leaves, keccak256, { sort: true })

        for (let i = 0; i < 3; i++) {
            const signer = accounts[i]
            const quantity = members[i]["amount"]

            const leaf = ethers.utils.solidityKeccak256(
                ["address", "uint256"],
                [signer.address, quantity]
            )
            const proof = tree.getHexProof(leaf)

            const tx = await airdropFacet.connect(signer).claim(quantity, proof)
            await tx.wait()
            console.log(`   ${signer.address} claimed!`)
        }

        console.log(`✔️  Airdrop done!`)
    });

function save(address: { [key: string]: string }) {
    const path = "./tasks/testnet/.address.json";
    fs.writeFileSync(
        path,
        JSON.stringify(address, null, "\t")
    )
}