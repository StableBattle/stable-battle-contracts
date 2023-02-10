import { BigNumber } from "ethers";
import { ethers } from "hardhat";
import { SBD as SBD_address } from "../config/goerli/main-contracts";

export default async function refreshOpenSea() {
  const SBD = await ethers.getContractAt("StableBattleDummy", "0xC0662fAee7C84A03B1e58d60256cafeeb08Ab85d");
  const eventsTransferSingle = await SBD.queryFilter(SBD.filters.TransferSingle());
  const eventsTransferBatch = await SBD.queryFilter(SBD.filters.TransferBatch());
  //All single transfer ids
  const singleIds = eventsTransferSingle.map(evt => evt.args.id);
  //All single transfers burned
  const singleBurned = eventsTransferSingle.map(evt => 
    evt.args.to == ethers.constants.AddressZero ? BigNumber.from(0) : evt.args.id);
  //All batch transfers ids
  const batchIds = eventsTransferBatch.map(evt => evt.args.ids);
  //All batch burned ids
  const batchBurned = eventsTransferBatch.map(evt => 
    evt.args.to == ethers.constants.AddressZero ? [BigNumber.from(0)] : evt.args.ids);
  let ids : BigNumber[] = [];
  //Add all ids from singles
  for(const id of singleIds) {
    ids.push(id);
  }
  //Add all ids from batches
  for(const batchId of batchIds) {
    for(const id of batchId) {
      ids.push(id);
    }
  }
  //Filter for burned in singles
  ids.filter(id => !singleBurned.includes(id));
  //Filter for burned in batches
  for(const batchId of batchBurned) {
    ids.filter(id => !batchId.includes(id));
  }
  /* Old code for updating only knights may be reusable
  const eventsKnightMinted = await SBD.queryFilter(SBD.filters.KnightMinted());
  const eventsKnightBurned = await SBD.queryFilter(SBD.filters.KnightBurned());
  const mintedIds = eventsKnightMinted.map(evt => evt.args.knightId);
  const burnedIds = eventsKnightBurned.map(evt => evt.args.knightId);
  const knightIds = mintedIds.filter(id => !burnedIds.includes(id));
  */
  //Request data with forced update from opensea api
  for(const id of ids) {
    await fetch(`https://testnets-api.opensea.io/api/v1/asset/${SBD.address}/${id}?force_update=true`);
    console.log(`Updated metadata for ${id}`);
  }
  console.log(`Updated info for ${ids.length} items!`);
}

refreshOpenSea().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});