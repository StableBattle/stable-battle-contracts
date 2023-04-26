import hre from "hardhat";

describe('TreasuryFacetTest', async function () {

  it('should be able to join a clan', async function () {

  const StableBattle = await hre.ethers.getContractAt(
    "IStableBattle",
    "0xc1b9ac6a9e823d15f824068eebf089d2b4b32291"
  );
    await StableBattle.joinClan(
      "115792089237316195423570985008687907853269984665640564039457584007913129639887",
      "43"
    );
  });

});