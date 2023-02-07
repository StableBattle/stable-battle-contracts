import hre from "hardhat";
import { expect } from "chai";
import "@nomicfoundation/hardhat-chai-matchers";
import { loadFixture } from "@nomicfoundation/hardhat-network-helpers";

import { COIN, CoinInterface, POOL } from "./libraries/DataStructures";
import SBFixture, { SBFixtureInterface } from "./libraries/SBFixture";
import CoinSetup from "./libraries/CoinSetup";

describe('KnightFacetTest', async function () {

  let SB : SBFixtureInterface;
  let Coin : CoinInterface;
  let mints = 0;

  before(async () => {
    SB = await loadFixture(SBFixture);
    Coin = await loadFixture(CoinSetup);
  })

  it('knight price should be correct', async () => {
    expect(SB.knightPrice.TEST).to.equal(await SB.Diamond.KnightFacet.getKnightPrice(1));

    expect(SB.knightPrice.USDT).to.equal(await SB.Diamond.KnightFacet.getKnightPrice(2));

    expect(SB.knightPrice.USDC).to.equal(await SB.Diamond.KnightFacet.getKnightPrice(3));
  })

  it('check that USDT work alright', async () => {
    for (const [coinName, coinNumber] of Object.entries(COIN)) {
      if (coinNumber == 2) {
        let price = SB.knightPrice[coinName]
        let balance_before = await Coin[coinName].balanceOf(SB.owner.address)
        await Coin[coinName].mint(SB.owner.address, price)
        let balance_after = await Coin[coinName].balanceOf(SB.owner.address)
        expect(balance_after.sub(balance_before)).to.equal(price)
        await Coin[coinName].approve(SB.Diamond.Address, price)
        let allowance = await Coin[coinName].allowance(SB.owner.address, SB.Diamond.Address)
        expect(allowance).to.equal(price)
      }
    }
  })

  //mintKnight(1, 1) == mint TEST TEST
  //mintKnight(2, 2) = mint AAVE USDT
  //mintKnight(2, 3) = mint AAVE USDC

  it('should mint a knight correctly for all valid combinations of Pool and Coin', async () => {
    for(const [poolName, poolNumber] of Object.entries(POOL)) {
      for(const [coinName, coinNumber] of Object.entries(COIN)) {
        if (await SB.Diamond.KnightFacet.getPoolAndCoinCompatibility(poolNumber, coinNumber) && 
            poolNumber == 2 && coinNumber == 2)
        {
          await SB.Diamond.KnightFacet.mintKnight(poolNumber, coinNumber);
          let eventsKnightMinted = await SB.Diamond.KnightFacet.queryFilter(SB.Diamond.KnightFacet.filters.KnightMinted());
          let [knightId, knightOwner, knightPool, KnightCoin] = eventsKnightMinted[mints].args
          expect(knightOwner).to.equal(SB.owner.address)
          expect(knightPool).to.equal(poolNumber)
          expect(KnightCoin).to.equal(coinNumber)
          let knightOwnerFromCall = await SB.Diamond.KnightFacet.getKnightOwner(knightId)
          expect(knightOwner).to.equal(knightOwnerFromCall)
          let knightPoolFromCall = await SB.Diamond.KnightFacet.getKnightPool(knightId)
          expect(knightPool).to.equal(knightPoolFromCall)
          let knightCoinFromCall = await SB.Diamond.KnightFacet.getKnightCoin(knightId)
          expect(KnightCoin).to.equal(knightCoinFromCall)
          mints++;
        }
      }
    }
  })

  it('should burn a knight correctly for all valid combinations of Pool and Coin', async () => {
    for(const [poolName, poolNumber] of Object.entries(POOL)) {
      for(const [coinName, coinNumber] of Object.entries(COIN)) {
        if (await SB.Diamond.KnightFacet.getPoolAndCoinCompatibility(poolNumber, coinNumber) && 
            poolNumber == 2 && coinNumber == 2)
        {
          let eventCount = (coinNumber - 2) + (poolNumber - 2) * mints;
          let eventsKnightMinted = await SB.Diamond.KnightFacet.queryFilter(SB.Diamond.KnightFacet.filters.KnightMinted())
          let [knightId, knightOwner, knightPool, KnightCoin] = eventsKnightMinted[eventCount].args
          
          let balance_before = await Coin[coinName].balanceOf(SB.owner.address)
          await SB.Diamond.KnightFacet.burnKnight(knightId, 0)
          let balance_after = await Coin[coinName].balanceOf(SB.owner.address)
          expect(balance_after.sub(balance_before)).to.equal(await SB.Diamond.KnightFacet.getKnightPrice(coinNumber))
          let eventsKnightBurned = await SB.Diamond.KnightFacet.queryFilter(SB.Diamond.KnightFacet.filters.KnightBurned())
          let [knightId2, knightOwner2, knightPool2, KnightCoin2] = eventsKnightBurned[eventCount].args
          expect(knightId).to.equal(knightId2)
          expect(knightOwner).to.equal(knightOwner2)
          expect(knightPool).to.equal(knightPool2)
          expect(KnightCoin).to.equal(KnightCoin2)

          let knightInfo = await SB.Diamond.KnightFacet.getKnightInfo(knightId)
          expect(knightInfo.pool).to.equal(0)
          expect(knightInfo.coin).to.equal(0)
          expect(knightInfo.owner).to.equal(hre.ethers.constants.AddressZero)
          mints++;
        }
      }
    }
  })
})
