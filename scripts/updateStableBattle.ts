import hre from "hardhat";
import { SBD } from "./config/goerli/main-contracts";
import { FacetCutAction } from "./libraries/diamond";

export default async function updateStableBattle() {
  const StableBattle = await hre.ethers.getContractAt("IStableBattle", SBD);
  const NewClanFacet = await hre.ethers.getContractFactory("ClanFacet");
  const newClanFacet = await NewClanFacet.deploy();
  await newClanFacet.deployed();
  console.log("New ClanFacet deployed: ", newClanFacet.address);
  const NewKnightFacet = await hre.ethers.getContractFactory("KnightFacet");
  const newKnightFacet = await NewKnightFacet.deploy();
  await newKnightFacet.deployed();
  console.log("New KnightFacet deployed: ", newKnightFacet.address);
  console.log("Add update for approveJoinClan and mintKnight")
  const cut = [{
    facetAddress: newClanFacet.address,
    action: FacetCutAction.Replace,
    functionSelectors: [
      StableBattle.interface.getSighash("approveJoinClan")
    ]
  },
  {
    facetAddress: newKnightFacet.address,
    action: FacetCutAction.Replace,
    functionSelectors: [
      StableBattle.interface.getSighash("mintKnight")
    ]
  }];
  console.log("Diamond cut: ", cut);
  const tx = await StableBattle.diamondCut(cut, hre.ethers.constants.AddressZero, "0x");
  console.log("Diamond cut tx: ", tx.hash);
  tx.wait();
  console.log("Completed diamond cut");
}

updateStableBattle().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});