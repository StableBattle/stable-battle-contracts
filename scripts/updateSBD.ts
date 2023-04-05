import { ethers } from "hardhat";
import hre from "hardhat";
import * as fs from "fs";
import * as conf from "./config/sb-init-addresses";
import { DiamondSelectors, FacetCutAction } from "./libraries/diamond";

export default async function initSBD() {
  const { BEER, SBV } = require("./config/"+hre.network.name+"/main-contracts.ts");
  const SBD = "0xC0662fAee7C84A03B1e58d60256cafeeb08Ab85d";

  // deploy SBInit
  // SBInit provides a function that is called when the diamond is upgraded to initialize state variables
  // Read about how the diamondCut function works here: https://eips.ethereum.org/EIPS/eip-2535#addingreplacingremoving-functions
  const SBUpgrade = await ethers.getContractFactory('SBUpgrade_0_0_6_to_0_0_18');
  const diamondUpgrade = await SBUpgrade.deploy({gasLimit: 3000000})
  await diamondUpgrade.deployed()
  console.log('SBUpgrade deployed:', diamondUpgrade.address)
// Remove old facets
  const cut = []
  const Loupe = await ethers.getContractAt('IDiamondLoupe', SBD);
  const oldFacets = await Loupe.facets();
  for (const oldFacet of oldFacets) {
    cut.push({
      facetAddress : oldFacet.facetAddress,
      action: FacetCutAction.Remove,
      functionSelectors: oldFacet.functionSelectors
    })
  }
// Deploy StableBattle facets
  console.log('')
  console.log('Deploying facets')
  const FacetNames = [
    'DiamondCutFacet',
    'DiamondLoupeFacet',
    'OwnershipFacet',
    'ItemsFacet',
    'ClanFacet',
    'KnightFacet',
  //'SBVHookFacet',
  //'TournamentFacet',
  //'TreasuryFacet',
  //'GearFacet',
    'EtherscanFacet',
  //'DemoFightFacet',
    'DebugFacet',
    'AccessControlFacet',
    'SiegeFacet'
  ]
  const facetData : { address : string, name: string }[] = []
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
    facetData.push({ address: facet.address, name: FacetName });
    console.log(`${FacetName} deployed: ${facet.address}`)
    if (FacetName === 'ItemsFacet') {
      cut.push({
        facetAddress: facet.address,
        action: FacetCutAction.Add,
        //Remove excessive supportsInterface(bytes4) inherited from OZ ERC1155
        functionSelectors: (new DiamondSelectors(facet)).removeBySignature(['supportsInterface']).selectors
      })
    } else {
      cut.push({
        facetAddress: facet.address,
        action: FacetCutAction.Add,
        functionSelectors: (new DiamondSelectors(facet)).selectors
      })
    }
    
    //Catalog deployment addresses in the config file
    fs.writeFileSync(
      `./scripts/config/${hre.network.name}/sb-facets.ts`,
      `export const ${FacetName} = "${facet.address}";` + "\n",
      {flag: "a"}
    )

    fs.writeFileSync(
      `./scripts/config/${hre.network.name}/sb-facets.txt`,
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
  
  let args = {
    AAVE_address: conf.AAVE[hre.network.name],

    USDT_address: conf.USDT[hre.network.name],
    USDC_address: conf.USDC[hre.network.name],
    EURS_address: conf.EURS[hre.network.name],

    AAVE_USDT_address: conf.AUSDT[hre.network.name],
    AAVE_USDC_address: conf.AUSDC[hre.network.name],
    AAVE_EURS_address: conf.AEURS[hre.network.name],

    BEER_address: BEER,
    SBV_address: SBV
  }
  // call to init function
  let functionCall = diamondUpgrade.interface.encodeFunctionData('SB_update', [args])
  tx = await diamondCut.diamondCut(cut, diamondUpgrade.address, functionCall)
  console.log('SBD cut tx: ', tx.hash)
  receipt = await tx.wait()
  if (!receipt.status) {
    throw Error(`SBD upgrade failed: ${tx.hash}`)
  }
  console.log('Completed StableBattle diamond cut')

  return {facets: facetData, address: diamondUpgrade.address};
}

exports.initSBD = initSBD