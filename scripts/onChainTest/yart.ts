import hre, { ethers } from "hardhat";

async function yart() {
  const StableBattle = await hre.ethers.getContractAt(
    "IStableBattle",
    "0xc1b9ac6a9e823d15f824068eebf089d2b4b32291"
  );
  const errorData = "0xde3cd267ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffcf";
  const decoded = StableBattle.interface.decodeErrorResult(
    StableBattle.interface.errors["ItemsModifiers_DontOwnThisItem(uint256)"],
    errorData
  )
  console.log(decoded);
  /*
  const tx = await StableBattle.joinClan(
    "115792089237316195423570985008687907853269984665640564039457584007913129639887",
    "43"
  );
  console.log("Join Clan tx: ", tx.hash);
  await tx.wait();
  console.log("Completed Join Clan");
  */
}

yart().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});