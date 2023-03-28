const { getSelectors, FacetCutAction } = require('./libraries/diamond.js')
const { CONTRACT_ADDRESS } = require("../contract-address");

async function main() {
    const diamondCut = await ethers.getContractAt('IDiamondCut', CONTRACT_ADDRESS[network.name]["Diamond"])

    const FacetNames = [
        'AirdropFacet'
    ]

    const cut = []
    for (const FacetName of FacetNames) {
        const Facet = await ethers.getContractFactory(FacetName)
        const facet = await Facet.deploy()
        await facet.deployed()
        console.log(`${FacetName} deployed: ${facet.address}`)
        cut.push({
            facetAddress: facet.address,
            action: FacetCutAction.Replace,
            functionSelectors: getSelectors(facet)
        })
    }

    const tx = await diamondCut.diamondCut(cut, ethers.constants.AddressZero, ethers.constants.HashZero)
    const receipt = await tx.wait()
    if (!receipt.status) {
        throw Error(`Diamond upgrade failed: ${tx.hash}`)
    }
    console.log('Completed diamond cut');
}

main();