import hre, { ethers } from "hardhat";
import { SBD as SBD_GO, BEER as BEER_GO } from "./config/goerli/main-contracts";
import { SBD as SBD_HH, BEER as BEER_HH } from "./config/hardhat/main-contracts";
import { AAVE as AAVE_address, AUSDT as AUSDT_address, USDT as UDST_address } from "./config/sb-init-addresses";
import * as fs from "fs";
import verify from "./verify";

export default async function deployPopulateEvents() {
  console.log("Deploying PopulateEvents");
  const network = hre.network.name;
  const SBD_address = network === 'goerli' ? SBD_GO : SBD_HH;
  const BEER_address = network === 'goerli' ? BEER_GO : BEER_HH;
  const PopulateEvents = await hre.ethers.getContractFactory("PopulateEvents");
//const populateEvents = await ethers.getContractAt('PopulateEvents', '0x3678A25b06bC533dC2bf5D7976188a2C576DfD4E')
  
  const populateEvents = await PopulateEvents.deploy(
    UDST_address[network],
    SBD_address,
    BEER_address,
    AAVE_address[network],
    AUSDT_address[network]);
  await populateEvents.deployed();
  console.log('PopulateEvents deployed:', populateEvents.address);

  fs.writeFileSync(
    `./scripts/config/${hre.network.name}/populate-events.ts`,
    `export const populateEventsAddress = "${populateEvents.address}"`,
    { flag: 'w' }
  );
  fs.writeFileSync(
    `./scripts/config/${hre.network.name}/populate-events.txt`,
    populateEvents.address,
    { flag: 'w' }
  );
  const USDT = await ethers.getContractAt('IERC20Mintable', UDST_address[network]);
  const approveTx = await USDT.approve(populateEvents.address, 1000000 * 10 ** 6);
  approveTx.wait();
  console.log('1000000 USDT approved for PopulateEvents: ', approveTx.hash);
  if(hre.network.name != "hardhat") {
    await verify(populateEvents.address,
      [UDST_address[network],
      SBD_address, BEER_address,
      AAVE_address[network],
      AUSDT_address[network]]);
  }
  return populateEvents.address;
}

deployPopulateEvents().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});