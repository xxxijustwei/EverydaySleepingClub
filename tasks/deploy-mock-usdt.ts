import { task, types } from "hardhat/config"

task("deploy-mock-usdt", "Deploys the mock usdt contract")
    .addOptionalParam("verify", "Set to true to verify mock usdt contract", false, types.boolean)
    .setAction(async (args) => {

        // @ts-ignore
        console.log(`🌐 Deploying mock usdt contract to ${network.name}`)

        console.log(`\n💻 Compiling contract...\n`)
        // @ts-ignore
        await run("compile");

        // @ts-ignore
        const mockUsdtFactory = await ethers.getContractFactory("MockUSDT")
        const mockUsdtContract = await mockUsdtFactory.deploy()

        console.log(`\n🚧 Waiting transaction ${mockUsdtContract.deployTransaction.hash} to be confirmed...`)
        await mockUsdtContract.deployTransaction.wait();

        const verify = args.verify;
        if (verify && process.env.ARBITRUM_API_KEY) {
            try {
                console.log(`\n🔎 Verifying contract...`)
                await mockUsdtContract.deployTransaction.wait(4)
                // @ts-ignore
                await run("verify:verify", {
                    address: mockUsdtContract.address
                });

                console.log(`✔️ Contract verified`)
            } catch (e: any) {
                if (!e.message.includes("Already Verified")) {
                    console.log("✔️ Error verifying contract.  Try delete the ./build folder and try again.")
                    console.log(e)
                } else {
                    console.log("❌ Contract already verified")
                }
            }
        } else if (verify) {
            console.log("❌ ARBITRUM_API_KEY missing. Skipping contract verification...")
        }

        // @ts-ignore
        console.log(`\n📦 Mock usdt contract deployed to ${mockUsdtContract.address} on ${network.name}`)
    })