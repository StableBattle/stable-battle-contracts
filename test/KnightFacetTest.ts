import hre from "hardhat";
import { BigNumber } from "ethers";
import { assert, expect } from "chai"

import deployStableBattle from "../scripts/deploy";
import SBDFromAddress from "./libraries/SBDFromAddress";
import useCoin from "./libraries/useCoin";
import usePool from "./libraries/usePool";
import { COIN, POOL } from "./libraries/coinsAndPools";

describe('KnightFacetTest', async function () {
  const [owner, user1, user2] = await hre.ethers.getSigners();
  interface knightPriceInterface {
    readonly [index: string]: BigNumber
  }
  const knightPrice : knightPriceInterface = {
    USDT : BigNumber.from(1e9),
    USDC : BigNumber.from(1e9),
    EURS : BigNumber.from(1e9),
    TEST : BigNumber.from(0)
  }
  const [SBDAddress, SBTAddress, SBVAddress] = await deployStableBattle();
  const SBD = await SBDFromAddress(SBDAddress);
//const SBT = await hre.ethers.getContractAt("ISBT", SBTAddress);
//const SBV = await hre.ethers.getContractAt("ISBV", SBVAddress);
  const Coin = await useCoin();
//const Pool = await usePool();

  it('knight price should be correct', async () => {
    assert.equal(knightPrice.TEST, await SBD.KnightFacet.getKnightPrice(1));

    assert.equal(knightPrice.USDT, await SBD.KnightFacet.getKnightPrice(2));

    assert.equal(knightPrice.USDC, await SBD.KnightFacet.getKnightPrice(3));
  })

  it('check that USDT work alright', async () => {
    for (const [coinName , coinNumber] of Object.entries(COIN)) {
      if (coinNumber >= 2) {
        let price = knightPrice[coinName]
        let balance_before = await Coin[coinName].balanceOf(owner.address)
        await Coin[coinName].mint(owner.address, price)
        let balance_after = await Coin[coinName].balanceOf(owner.address)
        expect(balance_after.sub(balance_before)).to.be.equal(price)
        await Coin[coinName].approve(SBDAddress, price)
        let allowance = await Coin[coinName].allowance(owner.address, SBDAddress)
        expect(allowance).to.equal(price)
      }
    }
  })

  //mintKnight(1, 1) == mint TEST TEST
  //mintKnight(2, 2) = mint AAVE USDT
  //mintKnight(2, 3) = mint AAVE USDC

  it('should mint a knight correctly for all valid combinations of Pool and Coin', async () => {
    let mints = 0;
    for(const [poolName , poolNumber] of Object.entries(POOL)) {
      for(const [coinName , coinNumber] of Object.entries(COIN)) {
        if (await SBD.KnightFacet.getPoolAndCoinCompatibility(poolNumber, coinNumber) && 
            poolNumber > 1 && coinNumber > 1)
        {
          let eventCount = (coinNumber - 2) + (poolNumber - 2) * mints;
          await SBD.KnightFacet.mintKnight(poolNumber, coinNumber);
          let eventsKnightMinted = await SBD.KnightFacet.queryFilter(SBD.KnightFacet.filters.KnightMinted());
          let [knightId, knightOwner, knightPool, KnightCoin] = eventsKnightMinted[eventCount].args
          expect(knightOwner).to.equal(owner.address)
          expect(knightPool).to.equal(poolNumber)
          expect(KnightCoin).to.equal(coinNumber)
          let knightOwnerFromCall = await SBD.KnightFacet.getKnightOwner(knightId)
          expect(knightOwner).to.equal(knightOwnerFromCall)
          let knightPoolFromCall = await SBD.KnightFacet.getKnightPool(knightId)
          expect(knightPool).to.equal(knightPoolFromCall)
          let knightCoinFromCall = await SBD.KnightFacet.getKnightCoin(knightId)
          expect(KnightCoin).to.equal(knightCoinFromCall)
          mints++;
        }
      }
    }
  })

  it('should burn a knight correctly for all valid combinations of Pool and Coin', async () => {
    let mints = 0;
    for(const [poolName , poolNumber] of Object.entries(POOL)) {
      for(const [coinName , coinNumber] of Object.entries(COIN)) {
        if (await SBD.KnightFacet.getPoolAndCoinCompatibility(poolNumber, coinNumber) && 
            poolNumber > 1 && coinNumber > 1)
        {
          let eventCount = (coinNumber - 2) + (poolNumber - 2) * mints;
          let eventsKnightMinted = await SBD.KnightFacet.queryFilter(SBD.KnightFacet.filters.KnightMinted())
          let [knightId, knightOwner, knightPool, KnightCoin] = eventsKnightMinted[eventCount].args
          
          let balance_before = await Coin[coinName].balanceOf(owner.address)
          await SBD.KnightFacet.burnKnight(knightId)
          let balance_after = await Coin[coinName].balanceOf(owner.address)
          expect(balance_after.sub(balance_before)).to.equal(await SBD.KnightFacet.getKnightPrice(coinNumber))
          let eventsKnightBurned = await SBD.KnightFacet.queryFilter(SBD.KnightFacet.filters.KnightBurned())
          let [knightId2, knightOwner2, knightPool2, KnightCoin2] = eventsKnightBurned[eventCount].args
          expect(knightId).to.equal(knightId2)
          expect(knightOwner).to.equal(knightOwner2)
          expect(knightPool).to.equal(knightPool2)
          expect(KnightCoin).to.equal(KnightCoin2)

          let knightInfo = await SBD.KnightFacet.getKnightInfo(knightId)
          expect(knightInfo.pool).to.equal(0)
          expect(knightInfo.coin).to.equal(0)
          expect(knightInfo.owner).to.equal(hre.ethers.constants.AddressZero)
          mints++;
        }
      }
    }
  })
})
