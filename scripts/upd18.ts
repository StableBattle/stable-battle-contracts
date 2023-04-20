import { ethers } from "hardhat";
import { FacetCutAction } from "./libraries/diamond";

async function upgradeStableBattle() {

  const SBD = "0xc1B9aC6A9E823d15F824068eeBf089D2b4B32291";
  const diamondCut = await ethers.getContractAt("DiamondCutFacet", SBD);
  
  const newClanFacet = await ethers.getContractAt(
    "ClanFacet",
    "0x17E54afEFc3ce6568B25D214b71AE69ACdEE1f79"
  );
  console.log("New ClanFacet deployed at: ", newClanFacet.address);

  const cut = [];
  cut.push({
    facetAddress: newClanFacet.address,
    action: FacetCutAction.Replace,
    functionSelectors: ["0xc31e0800", "0x3a61785a"]
  });

  let tx = await diamondCut.diamondCut([], ethers.constants.AddressZero, "0x");
  console.log("SBD upgrade tx: ", tx.hash)
  let receipt = await tx.wait()
  if (!receipt.status) {
    throw Error(`SBD upgrade failed: ${tx.hash}`)
  }
  console.log("Completed SB upgrade")
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
upgradeStableBattle().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
