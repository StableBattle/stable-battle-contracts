import { ethers } from "hardhat";
import hre from "hardhat";
import * as fs from "fs";

const { initSBD } = require('./initSBD.ts');

async function deployStableBattle () {
  const accounts = await ethers.getSigners()
  const contractOwner = accounts[0]
  //Check that config folder exists for this network & create one if not
  if (!fs.existsSync("./scripts/config/" + hre.network.name + "/")) {
    fs.mkdirSync("./scripts/config/" + hre.network.name + "/")
  }

// Deploy DiamondCut
  console.log("Deploying DiamondCut")
  // deploy DiamondCutFacet
  const DiamondCutFacet = await ethers.getContractFactory('DiamondCutFacet')
  const diamondCutFacet = await DiamondCutFacet.deploy({gasLimit: 3000000})
  await diamondCutFacet.deployed()
  console.log('DiamondCutFacet deployed:', diamondCutFacet.address)

  // write thier addresses in the config file
  fs.writeFileSync('./scripts/config/'+hre.network.name+'/shared-facets.ts', `
  export const diamondCutFacetAddress = "${diamondCutFacet.address}"
  `,
  { flag: 'w' })

//Deploy main contracts entry points
  console.log("Deploying main contracts")
  // deploy StableBattleDiamond
  const StableBattleDiamond = await ethers.getContractFactory('Diamond')
  const SBD = await StableBattleDiamond.deploy(contractOwner.address, diamondCutFacet.address, {gasLimit: 3000000})
  await SBD.deployed()
  console.log('StableBattle Diamond deployed:', SBD.address)

  // deploy StableBattleToken
  const SBTProxy = await ethers.getContractFactory('SBTProxy');
  const SBTImplementation = await ethers.getContractFactory('SBTImplementation');
  const implementationSBT = await SBTImplementation.deploy();
  await implementationSBT.deployed();
  const SBT = await SBTProxy.deploy(implementationSBT.address, contractOwner.address);
  await SBT.deployed();
  console.log('StableBattle Token deployed:', SBT.address)

  // deploy StableBattleVillages
  const SBVProxy = await ethers.getContractFactory('SBVProxy');
  const SBVImplementation = await ethers.getContractFactory('SBVImplementation');
  const implementationSBV = await SBVImplementation.deploy();
  await implementationSBV.deployed();
  const SBV = await SBVProxy.deploy(implementationSBV.address, contractOwner.address);
  await SBV.deployed();
  console.log('StableBattle Villages deployed:', SBV.address)
  
  // write their addresses in the config file
  fs.writeFileSync('./scripts/config/'+hre.network.name+'/main-contracts.ts', `
  export const SBD = "${SBD.address}"
  export const SBT = "${SBT.address}"
  export const SBV = "${SBV.address}"
  `,
  { flag: 'w' })
  
  fs.writeFileSync('./scripts/config/'+hre.network.name+'/main-contracts.txt', SBD.address, { flag: 'w' })

  //initialize StableBattle Diamond
  initSBD()

  //remember deploy block for tests that rely on block.timestamp/block.number calculation
  const predeployBlock = await ethers.provider.getBlock("latest")

  console.log('StableBattle deployed!')
  return[SBD.address, SBT.address, SBV.address, predeployBlock]
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
deployStableBattle().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});

exports.deployStableBattle = deployStableBattle
