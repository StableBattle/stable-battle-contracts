import hre from "hardhat";
import verify from "./verify";
import * as fs from "fs";


export default async function deployDummy(SBDAddress : string) {
  const Dummy = await hre.ethers.getContractFactory("StableBattleDummy");
  const dummy = await Dummy.deploy({ gasLimit: 3000000 });
  await dummy.deployed();

  if (hre.network.name != "hardhat") {
    console.log("  Dummy");
    await verify(dummy.address);
  }

  const EtherscanDummy = await hre.ethers.getContractAt("EtherscanFacet", SBDAddress);
  await EtherscanDummy.setDummyImplementation(dummy.address);

  
  fs.writeFileSync(
    `./scripts/config/${hre.network.name}/dummy-address.ts`,
    `export const dummy_address = "${dummy.address}"`,
    { flag: 'w' }
  );

  fs.writeFileSync(
    `./scripts/config/${hre.network.name}/dummy-address.txt`,
    `${dummy.address}`,
    { flag: 'w' }
  );
}