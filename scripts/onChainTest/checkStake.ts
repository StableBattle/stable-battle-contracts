import hre from "hardhat";
import { SBD as SBD_address } from "../config/goerli/main-contracts";
import { AUSDT as AUSDT_address } from "../config/sb-init-addresses";

export default async function checkStake() {
  const contractAddress = "0xC0662fAee7C84A03B1e58d60256cafeeb08Ab85d";
  const AUSDT = await hre.ethers.getContractAt("IERC20Mintable", AUSDT_address.goerli);
  const stake = await AUSDT.balanceOf(contractAddress);
  console.log(`Stake of address ${contractAddress} is ${stake}`)
}

checkStake().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});