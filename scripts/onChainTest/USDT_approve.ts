import hre from "hardhat";
import { SBD } from "../config/goerli/main-contracts";
import { USDT as USDT_address } from "../config/sb-init-addresses";

export default async function approveUSDT() {
  const myAddress = "0xFcB5320ad1C7c5221709A2d25bAdcb64B1ffF860";
  const USDT = await hre.ethers.getContractAt("IERC20Mintable", USDT_address[hre.network.name]);
  const tx = await USDT.approve(SBD, USDT.balanceOf(myAddress));
  tx.wait();
}

approveUSDT().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});