import hre from "hardhat";
import { SBD as SBD_address } from "../config/goerli/main-contracts";

export default async function setNewURI() {
  const SBD = await hre.ethers.getContractAt("StableBattleDummy", SBD_address);
  const tx = await SBD.adminSetBaseURI("http://test1.stablebattle.io:5000/api/nft/");
  tx.wait();
}

setNewURI().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});