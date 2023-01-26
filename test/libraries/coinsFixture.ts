import { BigNumber } from "ethers";
import hre, { ethers } from "hardhat";
import { AAVE_FAUCET, AAVE_FAUCET_OWNER } from "../../scripts/config/sb-init-addresses-v3";
import CoinSetup from "./CoinSetup";
import { COIN } from "./DataStructures";

export default async function coinsFixture() {
  const users = await hre.ethers.getSigners();
  const Coin = await CoinSetup();
  const faucetOwner = await ethers.getImpersonatedSigner(AAVE_FAUCET_OWNER.goerli);
  const faucet = await ethers.getContractAt("Faucet", AAVE_FAUCET.goerli);
  for (const user of users) {
    for (const [coinName, coinNumber] of Object.entries(COIN)) {
      if (coinName == "USDT") {
        const amount = (BigNumber.from(10).pow(await Coin[coinName].decimals())).mul(10000);
        await faucet.connect(faucetOwner).mint(Coin[coinName].address, user.address, amount)
      }
    }
  } 
}