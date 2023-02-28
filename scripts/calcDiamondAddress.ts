import hre from "hardhat";
import "@nomiclabs/hardhat-ethers";

export default async function calcDiamondAddress(salt : number) {
  const Create2Deployer = await hre.ethers.getContractFactory("Create2Deployer");
  const create2Deployer = await Create2Deployer.deploy({ gasLimit: 3000000 });
  await create2Deployer.deployed();
  const address = create2Deployer.getBytecode(salt);
  console.log(salt, address)
  return (address);
}