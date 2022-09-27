import hre from "hardhat";
import "@nomiclabs/hardhat-ethers";
import * as fs from "fs";

import initSBD from "./initSBD";
import verify from "./verify";

export default async function deployStableBattle():
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
  const SBTProxy = await hre.ethers.getContractFactory('SBTProxy');
  const SBTImplementation = await hre.ethers.getContractFactory('SBTImplementation');
  const implementationSBT = await SBTImplementation.deploy();
  await implementationSBT.deployed();
  const SBT = await SBTProxy.deploy(implementationSBT.address, contractOwner.address, SBD.address);
  await SBT.deployed();
  console.log('StableBattle Token deployed:', SBT.address);

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
export const SBT = "${SBT.address}"
export const SBV = "${SBV.address}"`,
    { flag: 'w' }
  );

  fs.writeFileSync(
    `./scripts/config/${hre.network.name}/main-contracts.txt`,
    `${SBD.address}
${SBT.address}
${SBV.address}`,
    { flag: 'w' }
  );

  //initialize StableBattle Diamond
  const initData = await initSBD()
  const facetData = [...[{address: diamondCutFacet.address, name: "DiamondCutFacet"}], ...(initData.facets)];

  const Dummy = await hre.ethers.getContractFactory("StableBattleDummy");
  const dummy = await Dummy.deploy({ gasLimit: 3000000 });
  await dummy.deployed();

  //remember deploy block for tests that rely on block.timestamp/block.number calculation
  const predeployBlock = await hre.ethers.provider.getBlock("latest");

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

    console.log("  Dummy");
    await verify(dummy.address);

    console.log("  Token:");
    console.log("    Proxy");
    await verify(SBT.address, [implementationSBT.address, contractOwner.address, SBD.address]);
    console.log("    Implementation");
    await verify(implementationSBT.address);

    console.log("  Vilages:");
    console.log("    Proxy");
    await verify(SBV.address, [implementationSBV.address, contractOwner.address, SBD.address]);
    console.log("    Implementation");
    await verify(implementationSBV.address);
  }

  const EtherscanDummy = await hre.ethers.getContractAt("EtherscanFacet", SBD.address);
  EtherscanDummy.setDummyImplementation(dummy.address);

  return [SBD.address, SBT.address, SBV.address, predeployBlock.number];
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
deployStableBattle().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});