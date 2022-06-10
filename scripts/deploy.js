/* global ethers */
/* eslint prefer-const: "off" */

const { initSBD } = require('./initSBD.js')
const { initSBT } = require('./initSBT.js')
const { initSBV } = require('./initSBV.js')

async function deployStableBattle () {
  
  const accounts = await ethers.getSigners()
  const contractOwner = accounts[0]

  // deploy DiamondCutFacet
  const DiamondCutFacet = await ethers.getContractFactory('DiamondCutFacet')
  const diamondCutFacet = await DiamondCutFacet.deploy({gasLimit: 3000000})
  await diamondCutFacet.deployed()
  console.log('DiamondCutFacet deployed:', diamondCutFacet.address)

  // deploy StableBattleDiamond
  const StableBattleDiamond = await ethers.getContractFactory('Diamond')
  const SBD = await StableBattleDiamond.deploy(contractOwner.address, diamondCutFacet.address, {gasLimit: 3000000})
  await SBD.deployed()
  console.log('StableBattleDiamond deployed:', SBD.address)

  // deploy StableBattleToken
  const StableBattleToken = await ethers.getContractFactory('Diamond')
  const SBT = await StableBattleToken.deploy(contractOwner.address, diamondCutFacet.address, {gasLimit: 3000000})
  await SBT.deployed()
  console.log('StableBattleToken deployed:', SBT.address)

  // deploy StableBattleVillages
  const StableBattleVillages = await ethers.getContractFactory('Diamond')
  const SBV = await StableBattleVillages.deploy(contractOwner.address, diamondCutFacet.address, {gasLimit: 3000000})
  await SBV.deployed()
  console.log('StableBattleVillages deployed:', SBV.address)

  const [Clan_address,
         Treasury_address] = await initSBD(SBD.address, SBT.address, SBV.address)
  await initSBT(SBT.address, Clan_address, Treasury_address)
  await initSBV(SBV.address)
  console.log('StableBattle deployed!')
  return[SBD.address, SBT.address, SBV.address]
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

exports.deployStableBattle = deployStableBattle
