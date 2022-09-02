import { ethers } from "hardhat";
import hre from "hardhat";

async function upgradeStableBattle() {

  const SBD = require("./config/"+hre.network.name+"/main-contracts.ts");
  const diamondCut = await ethers.getContractAt('DiamondCutFacet', SBD);
  
  const SBUpgrade = await ethers.getContractFactory('SBUpgrade');
  const diamondUpgrade = await SBUpgrade.deploy({gasLimit: 3000000});
  await diamondUpgrade.deployed();
  console.log('SBUpgrade deployed:', diamondUpgrade.address);

  let args = {
    castleTax: 22,
    rewardPerBlock: 110
  }

  let functionCall = diamondUpgrade.interface.encodeFunctionData('SB_upgrade', [args])
  let tx = await diamondCut.diamondCut([], diamondUpgrade.address, functionCall)
  console.log('SBD upgrade tx: ', tx.hash)
  let receipt = await tx.wait()
  if (!receipt.status) {
    throw Error(`SBD upgrade failed: ${tx.hash}`)
  }
  console.log('Completed SB upgrade')
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
upgradeStableBattle().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
