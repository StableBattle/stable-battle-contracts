import hre from "hardhat";
import { SBD as SBD_address, BEER as BEER_address } from "./config/goerli/main-contracts";
import { AAVE as AAVE_address, AUSDT as AUSDT_address, USDT as UDST_address } from "./config/sb-init-addresses";

export default async function deployStableBattle() {
  console.log("Deploying PopulateEvents");
  const PopulateEvents = await hre.ethers.getContractFactory("PopulateEvents");
  const populateEvents = await PopulateEvents.deploy(UDST_address, SBD_address, BEER_address, AAVE_address, AUSDT_address);
  await populateEvents.deployed();
  populateEvents.populateEvents();
  console.log('PopulateEvents deployed:', populateEvents.address);
}