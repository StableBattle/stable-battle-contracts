import { expect } from "chai";
import "@nomicfoundation/hardhat-chai-matchers";
import { loadFixture } from "@nomicfoundation/hardhat-network-helpers";

import { POOL, COIN, CoinInterface } from "./libraries/DataStructures";
import SBFixture, { SBFixtureInterface } from "./libraries/SBFixture";
import CoinSetup from "./libraries/CoinSetup";
import { BigNumber } from "ethers";
import coinsFixture from "./libraries/coinsFixture";

describe('SiegeFacetTest', async function () {
  let SB : SBFixtureInterface;
  let Coin : CoinInterface;

  let knight : BigNumber[] = [];
  let clanId : BigNumber;

  before(async function () {
    SB = await loadFixture(SBFixture);
    Coin = await loadFixture(CoinSetup);
    await loadFixture(coinsFixture);
    for (const user of SB.users) {
      for (const [coinName, coinNumber] of Object.entries(COIN)) {
        if (coinName == "USDT") {
          const amount = (BigNumber.from(10).pow(await Coin[coinName].decimals())).mul(10000);
          await Coin[coinName].connect(user).approve(SB.Diamond.Address, amount);
        }
      }
    }
    let mints = 0;
    for (const user of SB.users) {
      await SB.Diamond.KnightFacet.connect(user).mintKnight(POOL.AAVE, COIN.USDT);
      mints++;
    }
    const eventsKnightMinted = await SB.Diamond.KnightFacet.queryFilter(SB.Diamond.KnightFacet.filters.KnightMinted());
    for (let i = 0; i < mints; i++) {
      knight[i] = eventsKnightMinted[i].args.knightId;
      console.log(`Minted ${knight[i]} from ${eventsKnightMinted[i].args.wallet}`);
    }
    await SB.SBT.adminMint(SB.owner.address, (BigNumber.from(10).pow(await SB.SBT.decimals())).mul(1e6));
    await SB.Diamond.ClanFacet.createClan(knight[0], "💩💩💩");
    clanId = (await SB.Diamond.ClanFacet.queryFilter(SB.Diamond.ClanFacet.filters.ClanCreated()))[0].args.clanId;
  })

  it('Should assign clan 1 as winner and reward knight[0]', async () => {
    const reward = 
      (await Coin.AUSDT.balanceOf(SB.Diamond.Address))
      .sub(BigNumber.from(10).pow(await Coin.USDT.decimals()).mul(1000 * knight.length));
    await SB.Diamond.SiegeFacet.setSiegeWinner(1);
    expect(await SB.Diamond.SiegeFacet.getSiegeWinnerClanId()).to.equal(1);
    expect(await SB.Diamond.SiegeFacet.getSiegeWinnerKnightId()).to.equal(knight[0]);
  //expect(await SB.Diamond.SiegeFacet.getSiegeReward(knight[0])).to.equal(reward);
  });
})
