/* global describe it before ethers */

const { deployStableBattle } = require('../scripts/deploy.js')

const { assert, expect } = require('chai')

describe('KnightFacetTest', async function () {
  let USDT_address = ethers.utils.getAddress("0x21C561e551638401b937b03fE5a0a0652B99B7DD")
  let USDC_address = ethers.utils.getAddress("0x9aa7fEc87CA69695Dd1f879567CcF49F3ba417E2")
  let AAVE_address = ethers.utils.getAddress("0x6C9fB0D5bD9429eb9Cd96B85B81d872281771E6B")
  let knightPrice = { USDT: 1e9, USDC: 1e9, TEST: 0}
  let COIN = []
  let numberOfCoins = 2;
  let numberOfPools = 1;
  let owner
  let user1
  let user2
  let USDT
  let USDC
  let AAVE
  let SBD
  let SBT
  let SBV
  let tx
  let receipt
  let result
  //const addresses = []

  before(async function () {
    [owner, user1, user2] = await ethers.getSigners()
    USDT = await ethers.getContractAt('IERC20Mintable', USDT_address)
    USDC = await ethers.getContractAt('IERC20Mintable', USDC_address)
    COIN[1] = USDT; COIN[2] = USDC;
    AAVE = await ethers.getContractAt('IPool', AAVE_address)
    const [SBDAddress, SBTAddress, SBVAddress] = await deployStableBattle()
    SBD = {
      Address: SBDAddress,
      CutFacet: await ethers.getContractAt('DiamondCutFacet', SBDAddress),
      LoupeFacet: await ethers.getContractAt('DiamondLoupeFacet', SBDAddress),
      OwnershipFacet: await ethers.getContractAt('OwnershipFacet', SBDAddress),
      ClanFacet: await ethers.getContractAt('ClanFacet', SBDAddress),
      ItemsFacet: await ethers.getContractAt('ItemsFacet', SBDAddress),
      KnightFacet: await ethers.getContractAt('KnightFacet', SBDAddress),
      TournamentFacet: await ethers.getContractAt('TournamentFacet', SBDAddress),
      TreasuryFacet: await ethers.getContractAt('TreasuryFacet', SBDAddress),
      SBVHookFacet: await ethers.getContractAt('SBVHookFacet', SBDAddress),
      addresses: []
    }
    SBT = {
      Address: SBTAddress,
      CutFacet: await ethers.getContractAt('DiamondCutFacet', SBTAddress),
      LoupeFacet: await ethers.getContractAt('DiamondLoupeFacet', SBTAddress),
      OwnershipFacet: await ethers.getContractAt('OwnershipFacet', SBTAddress),
      SBTFacet: await ethers.getContractAt('SBTFacet', SBTAddress),
      addresses: []
    }
    SBV = {
      Address: SBVAddress,
      CutFacet: await ethers.getContractAt('DiamondCutFacet', SBVAddress),
      LoupeFacet: await ethers.getContractAt('DiamondLoupeFacet', SBVAddress),
      OwnershipFacet: await ethers.getContractAt('OwnershipFacet', SBVAddress),
      SBVFacet: await ethers.getContractAt('SBVFacet', SBVAddress),
      addresses: []
    }
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

  //mintKnight(1, 1) == mint AAVE USDT
  //mintKnight(1, 2) = mint AAVE USDC
  //mintKnight(2, 3) = mint TEST TEST

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
          expect(knightInfo.owner).to.equal(ethers.constants.AddressZero)
        }
      }
    }
  })
})
