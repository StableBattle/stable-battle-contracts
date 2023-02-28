import { BigNumber } from "ethers";
import { ethers } from "hardhat";
import * as fs from "fs";

interface NFT {
  id : BigNumber,
  amount : number
}

export default async function refreshOpenSea() {
  const SBD = await ethers.getContractAt("StableBattleDummy", "0xC0662fAee7C84A03B1e58d60256cafeeb08Ab85d");
  const knightsTotal = await SBD.getTotalKnightSupply();
  console.log(`${knightsTotal} knights in total`);
  
  const eventsKnightMinted = await SBD.queryFilter(SBD.filters.KnightMinted());
  const eventsKnightBurned = await SBD.queryFilter(SBD.filters.KnightBurned());
  const mintedIds = eventsKnightMinted.map(evt => evt.args.knightId);
  const burnedIds = eventsKnightBurned.map(evt => evt.args.knightId);
  const knightIds = mintedIds.filter(id => {
      for(const burnedId of burnedIds) {
        if(burnedId.eq(id)) {
          return false;
        }
      }
      return true;
    });

  console.log(`Parser found ${knightIds.length} knights`);
  //Request data with forced update from opensea api
  if (fs.existsSync("./metadata/failedIds.txt")) {
    fs.unlinkSync("./metadata/failedIds.txt")
  }
  //Set fetch timeout to 2 sec
  const controller = new AbortController()
  const timeoutId = setTimeout(() => controller.abort(), 5000)

  let failedIds : BigNumber[] = []
  for(const id of knightIds) {
    const response = await fetchWithTimeout(
      `https://testnets-api.opensea.io/api/v1/asset/${SBD.address}/${id}?force_update=true`,
      3000
    );
  //console.log(await response.json());
    if(!response.ok) {
      console.log(response.status);
      failedIds.push(id);
      fs.writeFileSync(
        `./scripts/metadata/failedIds.txt`,
        `${id}`,
        {flag: "a"}
      );
    }
    console.log(`Updated metadata for ${id}`);
  }
  console.log(failedIds);
  console.log(`Updated info for ${knightIds.length} items!`);
}

async function fetchWithTimeout(url : string, timeout: number) : Promise<Response> {
  return new Promise((resolve) => {
    setTimeout(() => {
      resolve(fetch(url));
    }, timeout);
  });
}

refreshOpenSea().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});