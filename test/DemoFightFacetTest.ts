import hre from "hardhat";
import { expect } from "chai";
import "@nomicfoundation/hardhat-chai-matchers";
import { loadFixture } from "@nomicfoundation/hardhat-network-helpers";

import { COIN, CoinInterface, POOL } from "./libraries/DataStructures";
import SBFixture, { SBFixtureInterface } from "./libraries/SBFixture";
import CoinSetup from "./libraries/CoinSetup";
import { BigNumber } from "ethers";
import coinsFixture from "./libraries/coinsFixture";

describe('DemoFightFacetTest', async function () {
  let SB : SBFixtureInterface;
  let Coin : CoinInterface;

  let knight : BigNumber[] = [];
  let clanId : BigNumber;
  let preTimeskipReward : BigNumber;
  let afterTimeskipReward : BigNumber;

  before(async function () {
    SB = await loadFixture(SBFixture);
    Coin = await loadFixture(CoinSetup);
    await loadFixture(coinsFixture);
    for (const user of SB.users) {
      for (const [coinName, coinNumber] of Object.entries(COIN)) {
        if (coinName == "USDT") {
          const amount = 10000 * 10 ** (await Coin[coinName].decimals());
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
    }
    await SB.SBT.adminMint(SB.owner.address, 1000);
  })

  it('Should show correct stake values', async () => {
    let totalYield = await SB.Diamond.DemoFightFacet.getTotalYield();
    let stakedByKnights = await SB.Diamond.DemoFightFacet.getStakedByKnights();
    preTimeskipReward = await SB.Diamond.DemoFightFacet.getCurrentYield();
  //console.log("totalYield: ", totalYield);
  //console.log("stakedByKnights: ", stakedByKnights);
  //console.log("currentReward: ", preTimeskipReward);
    expect(stakedByKnights).to.be.equal(20e9);
    expect(totalYield).to.be.at.least(stakedByKnights);
  //console.log("---------------------");
  })

  it('Should incerase stake as time passes', async () => {
    //0x64 = 10 blocks, 0x3c = 60 seconds
  //console.log("Timeskip 10 blocks, 60 seconds each")
    await hre.network.provider.send("hardhat_mine", ["0x3e8", "0x3c"]);
    afterTimeskipReward = await SB.Diamond.DemoFightFacet.getCurrentYield();
  //console.log("currentYield", afterTimeskipReward);
    expect(afterTimeskipReward).to.be.above(preTimeskipReward);
  //console.log("---------------------");
  })

  it('Should properly update battle results', async () => {
    let currentYield = await SB.Diamond.DemoFightFacet.getCurrentYield();
    await SB.Diamond.DemoFightFacet.battleWonBy(SB.users[0].address, currentYield);
    let lockedYield = await SB.Diamond.DemoFightFacet.getLockedYield();
    let userReward = await SB.Diamond.DemoFightFacet.getUserReward(SB.users[0].address);
    currentYield = await SB.Diamond.DemoFightFacet.getCurrentYield();
  //console.log("lockedYield: ", lockedYield);
  //console.log("userReward: ", userReward);
  //console.log("currentYield: ", currentYield);
    expect(lockedYield).to.be.at.least(afterTimeskipReward);
    expect(userReward).to.be.equal(lockedYield);
    expect(currentYield).to.at.least(0);
  //console.log("---------------------");
  })

  it('Should be able to claim reward correctly', async () => {
    let userReward = await SB.Diamond.DemoFightFacet.getUserReward(SB.users[0].address);
    let balanceBefore = await Coin["USDT"].balanceOf(SB.users[0].address);
    await SB.Diamond.DemoFightFacet.claimReward(SB.users[0].address);
    let balanceAfter = await Coin["USDT"].balanceOf(SB.users[0].address);
    expect(balanceAfter.sub(balanceBefore)).to.be.equal(userReward)
    let lockedYield = await SB.Diamond.DemoFightFacet.getLockedYield();
    userReward = await SB.Diamond.DemoFightFacet.getUserReward(SB.users[0].address);
  //console.log("lockedYield: ", lockedYield);
  //console.log("userReward: ", userReward);
    expect(lockedYield).to.be.equal(0);
    expect(userReward).to.be.equal(0);
  //console.log("---------------------");
  })

  it('Stake should not dip below 3000 USDC after reward claim', async () => {
    let totalYield = await SB.Diamond.DemoFightFacet.getTotalYield();
    let stakedByKnights = await SB.Diamond.DemoFightFacet.getStakedByKnights();
  //console.log("totalYield: ", totalYield);
  //console.log("stakedByKnights", stakedByKnights);
    expect(totalYield).to.be.at.least(stakedByKnights);
  //console.log("---------------------");
  })

})
