import hre from "hardhat";
import { SBD as SBD_address } from "../config/goerli/main-contracts";
import { USDT as USDT_address } from "../config/sb-init-addresses";

export default async function mintKnight() {
//const myAddress = "0xFcB5320ad1C7c5221709A2d25bAdcb64B1ffF860";
//const USDT = await hre.ethers.getContractAt("IERC20Mintable", USDT_address.goerli);
  const SBD = await hre.ethers.getContractAt("StableBattleDummy", SBD_address);
  const tx = await SBD.mintKnight(2, 2);
  tx.wait();
}

mintKnight().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});