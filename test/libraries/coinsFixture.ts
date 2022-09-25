import hre from "hardhat";
import CoinSetup from "./CoinSetup";
import { COIN } from "./DataStructures";

export default async function coinsFixture() {
  const users = await hre.ethers.getSigners();
  const Coin = await CoinSetup();
  for (const user of users) {
    for (const [coinName, coinNumber] of Object.entries(COIN)) {
      if (coinName == "USDT") {
        const amount = 10000 * 10 ** (await Coin[coinName].decimals());
        await Coin[coinName].mint(user.address, amount);
      }
    }
  } 
}