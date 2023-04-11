import hre, { ethers } from "hardhat";
import "@nomiclabs/hardhat-ethers";
import * as fs from "fs";

import initSBD from "./initSBD";
import verify from "./verify";
import deployDummy from "./deployDummy";

export default async function deployStableBattle() {
  const accounts = await hre.ethers.getSigners();
  const contractOwner = accounts[0];

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

  //Find diamnod and deploy other main contracts
  console.log("Deploying main contracts");
  //deploy StableBattleDiamond
  const SBD = await ethers.getContractAt('Diamond', "0xC0662fAee7C84A03B1e58d60256cafeeb08Ab85d");
  console.log('StableBattle Diamond found:', SBD.address);

  // deploy BEER token
  const BEERProxy = await hre.ethers.getContractFactory('BEERProxy');
  const BEERImplementation = await hre.ethers.getContractFactory('BEERImplementation');
  const implementationBEER = await BEERImplementation.deploy();
  await implementationBEER.deployed();
  const BEER = await BEERProxy.deploy(implementationBEER.address, contractOwner.address, SBD.address);
  await BEER.deployed();
  console.log('StableBattle Token deployed:', BEER.address);

  // deploy StableBattle Villages
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

  //update StableBattle Diamond
  const initData = await initSBD()
  const facetData = [...[{address: diamondCutFacet.address, name: "DiamondCutFacet"}], ...(initData.facets)];

  console.log('StableBattle deployed!');
  if (hre.network.name != "hardhat") {
    console.log("Verifying StableBattle:");
  
    console.log("  Diamond");
    await verify(SBD.address, [contractOwner.address, diamondCutFacet.address]);

    console.log("  Facets:");
    for (const facet of facetData) {
      console.log(`    ${facet.name}`)
      await verify(facet.address);
    }

    console.log("  Initializer");
    await verify(initData.address);

    console.log("  Token:");
    console.log("    Proxy");
    await verify(BEER.address, [implementationBEER.address, contractOwner.address, SBD.address]);
    console.log("    Implementation");
    await verify(implementationBEER.address);

    console.log("  Vilages:");
    console.log("    Proxy");
    await verify(SBV.address, [implementationSBV.address, contractOwner.address, SBD.address]);
    console.log("    Implementation");
    await verify(implementationSBV.address);
  }

  await deployDummy(SBD.address).catch((error) => {
    console.error(error);
    process.exitCode = 1;
  });
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
deployStableBattle().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});