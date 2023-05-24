import hre from "hardhat";
import { DiamondSelectors, FacetCutAction } from "./libraries/diamond";
import verify from "./verify";
import "dotenv/config";

export default async function updateStableBattle2() {
  const SBD = "0x6551C3EC64aA6E97097467Bd0fD69B4D49c155Be";
  const StableBattle = await hre.ethers.getContractAt("IStableBattle", SBD);

  //Retrieve current Facets and selectors
  const facets = await StableBattle.facets();
  let oldSelectors: string[] = [];
  for(const facet of facets) {
    oldSelectors = [...oldSelectors, ...facet.functionSelectors];
  }
  console.log('Old selectors: ', oldSelectors);
  
  //Deploy new Facets and add them to the diamond
  const FacetNames = [
    'ItemsFacet',
    'ClanFacet',
    'KnightFacet',
  //'SBVHookFacet',
  //'TournamentFacet',
  //'TreasuryFacet',
  //'GearFacet',
  //'DemoFightFacet',
    'DebugFacet',
    'AccessControlFacet',
    'SiegeFacet'
  ]
  const cut = [];
  let newSelectors: string[] = [];
  const newAddresses: string[] = [];

  for (const FacetName of FacetNames) {
    const Facet = await hre.ethers.getContractFactory(FacetName);
    const facet = await Facet.deploy({gasLimit: 5000000});
    await facet.deployed();
    newAddresses.push(facet.address);
    console.log(`${FacetName} deployed: ${facet.address}`)
    let selectors: string[] = []
    if (FacetName === 'ItemsFacet') {
      //Remove excessive supportsInterface(bytes4) inherited from OZ ERC1155
      selectors = (new DiamondSelectors(facet)).removeBySignature(['supportsInterface']).selectors
    } else {
      selectors = (new DiamondSelectors(facet)).selectors
    }
    newSelectors = [...newSelectors, ...selectors];
  //console.log('New selectors: ', selectors);
    const selectorsToAdd = selectors.filter((selector) => !oldSelectors.includes(selector));
    console.log('Selectors to add: ', selectorsToAdd);
    const selectorsToReplace = selectors.filter((selector) => oldSelectors.includes(selector));
    console.log('Selectors to replace: ', selectorsToReplace);
    if(selectorsToAdd.length > 0) {
      cut.push({
        facetAddress: facet.address,
        action: FacetCutAction.Add,
        functionSelectors: selectorsToAdd
      })
    }
    if(selectorsToReplace.length > 0) {
      cut.push({
        facetAddress: facet.address,
        action: FacetCutAction.Replace,
        functionSelectors: selectorsToReplace
      })
    }
  }
  const selectorsToRemove = oldSelectors.filter((selector) => !newSelectors.includes(selector));
  console.log('Selectors to remove: ', selectorsToRemove);
  cut.push({
    facetAddress: hre.ethers.constants.AddressZero,
    action: FacetCutAction.Remove,
    functionSelectors: selectorsToRemove
  })

  //Update the diamond
//const owner = await hre.ethers.getImpersonatedSigner(process.env.PUBLIC_KEY as string);
  const tx = await StableBattle.diamondCut(cut, hre.ethers.constants.AddressZero, "0x");
  console.log('SBD cut tx: ', tx.hash);
  const receipt = await tx.wait();
  if (!receipt.status) {
    throw Error(`SBD upgrade failed: ${tx.hash}`);
  }
  console.log('Completed StableBattle diamond cut');

  //Verify contracts on Etherscan
  if (hre.network.name != "hardhat") {
    console.log("Verifying facets");
    for(const address of newAddresses) {
      await verify(address);
    }
  }
}

updateStableBattle2().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
