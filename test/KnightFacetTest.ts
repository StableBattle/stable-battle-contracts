import hre from "hardhat";
import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";

const { deployStableBattle } = require('../scripts/deploy.js')

import { assert, expect } from "chai"

import { SBDInterface, SBDFromAddress } from "./libraries/SBDFromAddress";
import { IPool, ISBT, ISBV } from "../typechain-types";
import { AAVE as AAVE_address } from "../scripts/config/sb-init-addresses";

describe('KnightFacetTest', async function () {
  let owner : SignerWithAddress;
  let user1 : SignerWithAddress;
  let user2 : SignerWithAddress;
  let AAVE : IPool;
  let SBD : SBDInterface;
  let SBT : ISBT;
  let SBV : ISBV;

  before(async function () {
    [owner, user1, user2] = await hre.ethers.getSigners()
    AAVE = await hre.ethers.getContractAt('IPool', AAVE_address[hre.network.name])
    const [SBDAddress, SBTAddress, SBVAddress] = await deployStableBattle()
    SBD = await SBDFromAddress(SBDAddress);
    SBT = await hre.ethers.getContractAt("ISBT", SBTAddress);
    SBV = await hre.ethers.getContractAt("ISBV", SBVAddress);
  })

  it('knight price should be correct', async () => {
    let knightPriceFromCall = await SBD.KnightFacet.getKnightPrice(1)
    assert.equal(knightPrice.USDT, knightPriceFromCall)

    knightPriceFromCall = await SBD.KnightFacet.getKnightPrice(2)
    assert.equal(knightPrice.USDC, knightPriceFromCall)

    knightPriceFromCall = await SBD.KnightFacet.getKnightPrice(3)
    assert.equal(knightPrice.TEST, knightPriceFromCall)
  })

  it('check that Coins work alright', async () => {
    for (let c = 1; c < numberOfCoins + 1; c++) {
      let price = await await SBD.KnightFacet.getKnightPrice(c)
      let balance_before = await COIN[c].balanceOf(owner.address)
      await COIN[c].mint(price)
      let balance_after = await COIN[c].balanceOf(owner.address)
      assert.equal(balance_after - balance_before, price)
      await COIN[c].approve(SBD.Address, price)
      let allowance = await COIN[c].allowance(owner.address, SBD.Address)
      expect(allowance).to.equal(price)
    }
  })

  //mintKnight(1, 1) == mint TEST TEST
  //mintKnight(2, 2) = mint AAVE USDT
  //mintKnight(2, 3) = mint AAVE USDC

  it('should mint a knight correctly for all valid combinations of Pool and Coin', async () => {
    for(let p = 1; p < numberOfPools + 1; p++) {
      for(let c = 1; c < numberOfCoins + 1; c++) {
        if (await SBD.KnightFacet.getPoolAndCoinCompatibility(p, c)) {
          let eventCount = (c - 1) + (p - 1) * numberOfCoins
          await SBD.KnightFacet.mintKnight(p, c)
          let eventsKnightMinted = await SBD.KnightFacet.queryFilter('KnightMinted')
          let [knightId, knightOwner, knightPool, KnightCoin] = eventsKnightMinted[eventCount].args
          expect(knightOwner).to.equal(owner.address)
          expect(knightPool).to.equal(p)
          expect(KnightCoin).to.equal(c)
          let knightOwnerFromCall = await SBD.KnightFacet.getKnightOwner(knightId)
          expect(knightOwner).to.equal(knightOwnerFromCall)
          let knightPoolFromCall = await SBD.KnightFacet.getKnightPool(knightId)
          expect(knightPool).to.equal(knightPoolFromCall)
          let knightCoinFromCall = await SBD.KnightFacet.getKnightCoin(knightId)
          expect(KnightCoin).to.equal(knightCoinFromCall)
        }
      }
    }
  })

  it('should burn a knight correctly for all valid combinations of Pool and Coin', async () => {
    for(let p = 1; p < numberOfPools + 1; p++) {
      for(let c = 1; c < numberOfCoins + 1; c++) {
        if (await SBD.KnightFacet.getPoolAndCoinCompatibility(p, c)) {
          let eventCount = (c - 1) + (p - 1) * numberOfCoins
          let eventsKnightMinted = await SBD.KnightFacet.queryFilter('KnightMinted')
          let [knightId, knightOwner, knightPool, KnightCoin] = eventsKnightMinted[eventCount].args
          
          let balance_before = await COIN[c].balanceOf(owner.address)
          await SBD.KnightFacet.burnKnight(knightId)
          let balance_after = await COIN[c].balanceOf(owner.address)
          expect(balance_after - balance_before).to.equal(await SBD.KnightFacet.getKnightPrice(c))
          let eventsKnightBurned = await SBD.KnightFacet.queryFilter('KnightBurned')
          let [knightId2, knightOwner2, knightPool2, KnightCoin2] = eventsKnightBurned[eventCount].args
          expect(knightId).to.equal(knightId2)
          expect(knightOwner).to.equal(knightOwner2)
          expect(knightPool).to.equal(knightPool2)
          expect(KnightCoin).to.equal(KnightCoin2)

          let knightInfo = await SBD.KnightFacet.getKnightInfo(knightId)
          expect(knightInfo.pool).to.equal(0)
          expect(knightInfo.coin).to.equal(0)
          expect(knightInfo.owner).to.equal(hre.ethers.constants.AddressZero)
        }
      }
    }
  })
})
