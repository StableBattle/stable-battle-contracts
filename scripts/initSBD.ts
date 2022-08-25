import { ethers } from "hardhat";
import hre from "hardhat";
import * as fs from "fs";
import * as conf from "./config/sb-init-addresses";

const { getSelectors, FacetCutAction } = require("./libraries/diamond.js");

async function initSBD () {
  const { SBD, SBT, SBV } = require("./config/"+hre.network.name+"/main-contracts.ts");

  // deploy SBInit
  // SBInit provides a function that is called when the diamond is upgraded to initialize state variables
  // Read about how the diamondCut function works here: https://eips.ethereum.org/EIPS/eip-2535#addingreplacingremoving-functions
  const SBInit = await ethers.getContractFactory('SBInit')
  const diamondInit = await SBInit.deploy({gasLimit: 3000000})
  await diamondInit.deployed()
  console.log('SBInit deployed:', diamondInit.address)

// Deploy StableBattle facets
  console.log('')
  console.log('Deploying facets')
  const FacetNames = [
    'DiamondLoupeFacet',
    'OwnershipFacet',
    'ItemsFacet',
    'ClanFacet',
    'KnightFacet',
    'SBVHookFacet',
    'TournamentFacet',
    'TreasuryFacet',
    'GearFacet',
    'EtherscanFacet'
  ]
  const cut = []
  //Clear config files if they exist
  if (fs.existsSync("./scripts/config/"+hre.network.name+"/sb-facets.ts")) {
    fs.unlinkSync("./scripts/config/"+hre.network.name+"/sb-facets.ts")
  }
  if (fs.existsSync("./scripts/config/"+hre.network.name+"/sb-facets.txt")) {
    fs.unlinkSync("./scripts/config/"+hre.network.name+"/sb-facets.txt")
  }
  //Deploy the facets
  for (const FacetName of FacetNames) {
    const Facet = await ethers.getContractFactory(FacetName)
    const facet = await Facet.deploy({gasLimit: 5000000})
    await facet.deployed()
    console.log(`${FacetName} deployed: ${facet.address}`)
    if (FacetName === 'ItemsFacet') {
      cut.push({
        facetAddress: facet.address,
        action: FacetCutAction.Add,
        functionSelectors: getSelectors(facet).remove(['0x01ffc9a7'])
      })
    } else {
      cut.push({
        facetAddress: facet.address,
        action: FacetCutAction.Add,
        functionSelectors: getSelectors(facet)
      })
    }
    
    //Catalog deployment addresses in the config file
    fs.writeFileSync
    (
      "./scripts/config/"+hre.network.name+"/sb-facets.ts",
      "export const " + FacetName + " = " + facet.address + ";\n",
      {flag: "a"}
    )

    fs.writeFileSync
    (
      "./scripts/config/"+hre.network.name+"/sb-facets.txt",
      facet.address + "\n",
      {flag: "a"}
    )
  }

  // upgrade SBD with facets
  console.log('')
  //console.log('Diamond Cut:', cut)
  const diamondCut = await ethers.getContractAt('IDiamondCut', SBD)
  let tx
  let receipt

  let AAVE_address = ethers.constants.AddressZero
  let USDT_address = ethers.constants.AddressZero
  let USDC_address = ethers.constants.AddressZero
  let EURS_address = ethers.constants.AddressZero
  let AAVE_USDT_address = ethers.constants.AddressZero
  let AAVE_USDC_address = ethers.constants.AddressZero
  let AAVE_EURS_address = ethers.constants.AddressZero

  if (hre.network.name === 'mumbai') {
    AAVE_address = conf.AAVE_address.mumbai;

    USDT_address = conf.USDT_address.mumbai;
    USDC_address = conf.USDC_address.mumbai;
    EURS_address = conf.EURS_address.mumbai;
    
    AAVE_USDT_address = conf.AAVE_USDT_address.mumbai;
    AAVE_USDC_address = conf.AAVE_USDC_address.mumbai;
    AAVE_EURS_address = conf.AAVE_EURS_address.mumbai;
  } else if (hre.network.name === 'hardhat' || hre.network.name === 'goerli') {
    AAVE_address = conf.AAVE_address.goerli;

    USDT_address = conf.USDT_address.goerli;
    USDC_address = conf.USDC_address.goerli;
    EURS_address = conf.EURS_address.goerli;
    
    AAVE_USDT_address = conf.AAVE_USDT_address.goerli;
    AAVE_USDC_address = conf.AAVE_USDC_address.goerli;
    AAVE_EURS_address = conf.AAVE_EURS_address.goerli;
  }

  let args = {
    AAVE_address: AAVE_address,

    USDT_address: USDT_address,
    USDC_address: USDC_address,
    EURS_address: EURS_address,

    AAVE_USDT_address: AAVE_USDT_address,
    AAVE_USDC_address: AAVE_USDC_address,
    AAVE_EURS_address: AAVE_EURS_address,

    SBT_address: SBT,
    SBV_address: SBV
  }
  // call to init function
  let functionCall = diamondInit.interface.encodeFunctionData('SB_init', [args])
  tx = await diamondCut.diamondCut(cut, diamondInit.address, functionCall)
  console.log('SBD cut tx: ', tx.hash)
  receipt = await tx.wait()
  if (!receipt.status) {
    throw Error(`SBD upgrade failed: ${tx.hash}`)
  }
  console.log('Completed SB diamond cut')
}

exports.initSBD = initSBD