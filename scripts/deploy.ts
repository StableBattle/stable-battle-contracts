import hre from "hardhat";
import "@nomiclabs/hardhat-ethers";
import * as fs from "fs";

import initSBD from "./initSBD";

export default async function deploy():
  Promise<[string, string, string, number]> {
  const accounts = await hre.ethers.getSigners();
  const contractOwner = accounts[0];
  //Check that config folder exists for this network & create one if not
  if (!fs.existsSync(`./scripts/config/${hre.network.name}/`)) {
    fs.mkdirSync(`./scripts/config/${hre.network.name}/`);
  }

  // Deploy DiamondCut
  console.log("Deploying DiamondCut");
  // deploy DiamondCutFacet
  const DiamondCutFacet = await hre.ethers.getContractFactory("DiamondCutFacet");
  const diamondCutFacet = await DiamondCutFacet.deploy({ gasLimit: 3000000 });
  await diamondCutFacet.deployed();
  console.log('DiamondCutFacet deployed:', diamondCutFacet.address);

  // write thier addresses in the config file
  fs.writeFileSync(
    `./scripts/config/${hre.network.name}/shared-facets.ts`,
    `export const diamondCutFacetAddress = "${diamondCutFacet.address}"`,
    { flag: 'w' }
  );
  fs.writeFileSync(
    `./scripts/config/${hre.network.name}/shared-facets.txt`,
    diamondCutFacet.address,
    { flag: 'w' }
  );

  //Deploy main contracts entry points
  console.log("Deploying main contracts");
  // deploy StableBattleDiamond
  const StableBattleDiamond = await hre.ethers.getContractFactory('Diamond');
  const SBD = await StableBattleDiamond.deploy(contractOwner.address, diamondCutFacet.address, { gasLimit: 3000000 });
  await SBD.deployed();
  console.log('StableBattle Diamond deployed:', SBD.address);

  // deploy StableBattleToken
  const BEERProxy = await hre.ethers.getContractFactory('BEERProxy');
  const BEERImplementation = await hre.ethers.getContractFactory('BEERImplementation');
  const implementationBEER = await BEERImplementation.deploy();
  await implementationBEER.deployed();
  const BEER = await BEERProxy.deploy(implementationBEER.address, contractOwner.address, SBD.address);
  await BEER.deployed();
  console.log('StableBattle Token deployed:', BEER.address);

  // deploy StableBattleVillages
  const SBVProxy = await hre.ethers.getContractFactory('SBVProxy');
  const SBVImplementation = await hre.ethers.getContractFactory('SBVImplementation');
  const implementationSBV = await SBVImplementation.deploy();
  await implementationSBV.deployed();
  const SBV = await SBVProxy.deploy(implementationSBV.address, contractOwner.address, SBD.address);
  await SBV.deployed();
  console.log('StableBattle Villages deployed:', SBV.address);

  // write their addresses in the config files
  fs.writeFileSync(
    `./scripts/config/${hre.network.name}/main-contracts.ts`,
    `export const SBD = "${SBD.address}"
export const BEER = "${BEER.address}"
export const SBV = "${SBV.address}"`,
    { flag: 'w' }
  );

  fs.writeFileSync(
    `./scripts/config/${hre.network.name}/main-contracts.txt`,
    `${SBD.address}
${BEER.address}
${SBV.address}`,
    { flag: 'w' }
  );

  //initialize StableBattle Diamond
  await initSBD()

  //remember deploy block for tests that rely on block.timestamp/block.number calculation
  const predeployBlock = await hre.ethers.provider.getBlock("latest");

  console.log('StableBattle deployed!');

  return [SBD.address, BEER.address, SBV.address, predeployBlock.number];
}