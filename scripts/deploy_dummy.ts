import { ethers } from "hardhat";
import hre from "hardhat";
import * as fs from "fs";

async function deployDummy () {
  //Deploy dummy
  const Dummy = await ethers.getContractFactory('StableBattleDummy');
  const dummy = await Dummy.deploy();
  await dummy.deployed();
  console.log('Dummy deployed: ', dummy.address);

  //Check that config exists and if so delete it
  if (fs.existsSync("./scripts/dep_args/dummy-address.txt")) {
    fs.unlinkSync("./scripts/dep_args/dummy-address.txt");
  }
  if (fs.existsSync("./scripts/dep_args/dummy-address.ts")) {
    fs.unlinkSync("./scripts/dep_args/dummy-address.ts");
  }

  //Write down deployment parameters
  fs.writeFileSync(
    './scripts/config/'+hre.network.name+'/dummy-address.ts',
    `export const dummy_address = "${dummy.address}"`,
    { flag: 'w' }
  );
  fs.writeFileSync(
    './scripts/config/'+hre.network.name+'/dummy-address.txt',
    dummy.address,
    { flag: 'w' }
  );

  return dummy.address;
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
if (require.main === module) {
  deployDummy()
    .then(() => process.exit(0))
    .catch(error => {
      console.error(error)
      process.exit(1)
    })
}

exports.deployDummy = deployDummy
