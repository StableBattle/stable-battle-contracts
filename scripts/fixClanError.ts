import hre from "hardhat";
import { SBD } from "./config/goerli/main-contracts";
import { FacetCutAction } from "./libraries/diamond";

export default async function fixClanError() {
  const StableBattle = await hre.ethers.getContractAt("IStableBattle", SBD);
  const NewClanFacet = await hre.ethers.getContractFactory("ClanFacet");
  const newClanFacet = await NewClanFacet.deploy();
  await newClanFacet.deployed();
  console.log("New ClanFacet deployed: ", newClanFacet.address);
  const cut = [{
    facetAddress: newClanFacet.address,
    action: FacetCutAction.Replace,
    functionSelectors: ["0x1456388a"]
  }];
  const tx = await StableBattle.diamondCut(cut, hre.ethers.constants.AddressZero, "0x");
  console.log("Diamond cut tx: ", tx.hash);
  tx.wait();
  console.log("Completed diamond cut");
}

fixClanError().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});