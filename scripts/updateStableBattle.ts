import hre from "hardhat";
//import { SBD } from "./config/goerli/main-contracts";
import { FacetCutAction } from "./libraries/diamond";

export default async function updateStableBattle() {
  const SBD = "0x6551C3EC64aA6E97097467Bd0fD69B4D49c155Be";
  const StableBattle = await hre.ethers.getContractAt("IStableBattle", SBD);
  
  const NewClanFacet = await hre.ethers.getContractFactory("ClanFacet");
  const newClanFacet = await NewClanFacet.deploy();
  await newClanFacet.deployed();
  console.log("New ClanFacet deployed: ", newClanFacet.address);
  const newSigHashes = Object.keys(NewClanFacet.interface.functions)
    .map((key) => hre.ethers.utils.id(key).substring(0, 10));
  console.log("New ClanFacet sig hashes: ", newSigHashes);
  const cut = [
    {
      facetAddress: newClanFacet.address,
      action: FacetCutAction.Replace,
      functionSelectors: newSigHashes
    }
  ];
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