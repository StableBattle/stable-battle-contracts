import { ethers } from "hardhat";
import hre from "hardhat";
import * as fs from "fs";
import * as conf from "./config/sb-init-addresses";
import { DiamondSelectors, FacetCutAction } from "./libraries/diamond";

export default async function initSBD() {
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
  //'TournamentFacet',
    'TreasuryFacet',
    'GearFacet',
    'EtherscanFacet',
  //'DemoFightFacet',
    'AdminFacet',
    'AccessControlFacet',
    'SiegeFacet'
  ]
  const cut = []
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
  console.log('Completed StableBattle diamond cut')

  return {facets: facetData, address: diamondInit.address};
}

exports.initSBD = initSBD