/* global ethers fs */
/* eslint prefer-const: "off" */

const { ethers } = require('hardhat');
const { getSelector, FacetCutAction } = require('./libraries/diamond.js')

async function upgradeStableBattle() {
  const StableBattleAddress = "0xC0662fAee7C84A03B1e58d60256cafeeb08Ab85d";

  const DiamondCutFacet = await ethers.getContractAt('DiamondCutFacet', StableBattleAddress)

  const SBUpgrade = await ethers.getContractFactory("SBUpgrade");
  const diamondUpgrade = await SBUpgrade.deploy({gasLimit: 3000000})
  await diamondUpgrade.deployed()
  console.log('SBUpgrade deployed:', diamondUpgrade.address)

  const ItemsFacet = await ethers.getContractFactory("ItemsFacet")
  const newItemsFacet = await ItemsFacet.deploy({gasLimit: 5000000})
  await newItemsFacet.deployed()
  console.log(`New ItemsFacet deployed: ${newItemsFacet.address}`)
  const uriSelector = ItemsFacet.interface.getSighash("uri(uint256)");

  cut = [{
    facetAddress: newItemsFacet.address,
    action: FacetCutAction.Replace,
    functionSelectors: [uriSelector]
  }]

  let functionCall = diamondUpgrade.interface.encodeFunctionData('SB_upgrade')
  tx = await DiamondCutFacet.diamondCut(cut, diamondUpgrade.address, functionCall)
  console.log('SBD upgrade tx: ', tx.hash)
  receipt = await tx.wait()
  if (!receipt.status) {
    throw Error(`SBD upgrade failed: ${tx.hash}`)
  }
  console.log('Completed SB upgrade')
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
if (require.main === module) {
  upgradeStableBattle()
    .then(() => process.exit(0))
    .catch(error => {
      console.error(error)
      process.exit(1)
    })
}
