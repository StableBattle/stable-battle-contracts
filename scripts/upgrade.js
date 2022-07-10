/* global ethers fs */
/* eslint prefer-const: "off" */

async function upgradeStableBattle(StableBattleAddress) {

  const DiamondCutFacet = await ethers.getContractAt('DiamondCutFacet', StableBattleAddress)

  const diamondUpgrade = await SBUpgrade.deploy({gasLimit: 3000000})
  await diamondUpgrade.deployed()
  console.log('SBUpgrade deployed:', diamondUpgrade.address)

  let castleTax = 22
  let rewardPerBlock = 110
  let args = [[
    castleTax,
    rewardPerBlock
  ]]

  let functionCall = diamondUpgrade.interface.encodeFunctionData('SB_upgrade', args)
  tx = await diamondCut.diamondCut([], diamondUpgrade.address, functionCall)
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
  deployStableBattle()
    .then(() => process.exit(0))
    .catch(error => {
      console.error(error)
      process.exit(1)
    })
}
