/* global ethers fs */
/* eslint prefer-const: "off" */
const fs = require('fs')

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
  
  if (fs.existsSync("./scripts/dep_args/facet_addresses.txt")) {
    fs.unlinkSync("./scripts/dep_args/facet_addresses.txt")
  }
  const predeployBlock = await initSBD(SBD.address, SBT.address, SBV.address)
  await initSBT(SBD.address, SBT.address)
  await initSBV(SBD.address, SBV.address)
  console.log('StableBattle deployed!')
  
  if (fs.existsSync("./scripts/dep_args/diamond_addresses.txt")) {
    fs.unlinkSync("./scripts/dep_args/diamond_addresses.txt")
  }  
  if (fs.existsSync("./scripts/dep_args/DiamondCutFacet_address.txt")) {
    fs.unlinkSync("./scripts/dep_args/DiamondCutFacet_address.txt")
  }

  fs.writeFileSync(
    "./scripts/dep_args/diamond_addresses.txt",
    SBD.address + "\n" +
    SBT.address + "\n" +
    SBV.address,
    {flag: "a"})
  fs.writeFileSync("./scripts/dep_args/DiamondCutFacet_address.txt",
                   diamondCutFacet.address,
                   {flag: "a"})
  return[SBD.address, SBT.address, SBV.address, predeployBlock]
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
