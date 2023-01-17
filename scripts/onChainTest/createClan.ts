import hre from "hardhat";
import { SBD as SBD_address } from "../config/goerli/main-contracts";

export default async function createClan() {
//const myAddress = "0xFcB5320ad1C7c5221709A2d25bAdcb64B1ffF860";
//const USDT = await hre.ethers.getContractAt("IERC20Mintable", USDT_address.goerli);
  const SBD = await hre.ethers.getContractAt("StableBattleDummy", SBD_address);
  const tx = await SBD.createClan("115792089237316195423570985008687907853269984665640564039457584007913129639935");
  tx.wait();
}

createClan().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});