/* global describe it before ethers */

const {
  getSelectors,
  FacetCutAction,
  removeSelectors,
  findAddressPositionInFacets
} = require('../scripts/libraries/diamond.js')

const { deployStableBattle } = require('../scripts/deploy.js')

const { assert, expect } = require('chai')

describe('KnightFacetTest', async function () {
  let USDT_address = ethers.utils.getAddress("0x21C561e551638401b937b03fE5a0a0652B99B7DD")
  let AAVE_address = ethers.utils.getAddress("0x6C9fB0D5bD9429eb9Cd96B85B81d872281771E6B")
  let knightPrice = { AAVE: 1e9, OTHER: 0}
  let owner
  let user1
  let user2
  let USDT
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
    AAVE = await ethers.getContractAt('IPool', AAVE_address)
    const [SBDAddress, SBTAddress, SBVAddress] = await deployStableBattle()
    SBD = {
      Address: SBDAddress,
      CutFacet: await ethers.getContractAt('DiamondCutFacet', SBDAddress),
      LoupeFacet: await ethers.getContractAt('DiamondLoupeFacet', SBDAddress),
      OwnershipFacet: await ethers.getContractAt('OwnershipFacet', SBDAddress),
      ClanFacet: await ethers.getContractAt('ClanFacet', SBDAddress),
      ForgeFacet: await ethers.getContractAt('ForgeFacet', SBDAddress),
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
    assert.equal(knightPrice.AAVE, knightPriceFromCall)
  })

  it('check that USDT works alright', async () => {
    let balance_before = await USDT.balanceOf(owner.address)
    await USDT.mint(knightPrice.AAVE * 10)
    let balance_after = await USDT.balanceOf(owner.address)
    assert.equal(balance_after - balance_before, knightPrice.AAVE * 10)
    await USDT.approve(SBD.Address, knightPrice.AAVE)
    let allowance = await USDT.allowance(owner.address, SBD.Address)
    expect(allowance).to.equal(knightPrice.AAVE)
  })

  it('should mint a knight correctly', async () => {
    //mintKnight(1) == mint AAVE, mintKnight(2) = mintOTHER
    await USDT.mint(knightPrice.AAVE * 10)
    await USDT.approve(SBD.Address, knightPrice.AAVE)
    await SBD.KnightFacet.mintKnight(1)
    let eventsKnightMinted = await SBD.KnightFacet.queryFilter('KnightMinted')
    let [knightId, knightOwner, knightType] = eventsKnightMinted[0].args
    expect(knightOwner).to.equal(owner.address)
    let knightOwnerFromCall = await SBD.KnightFacet.getKnightOwner(knightId)
    expect(knightOwner).to.equal(knightOwnerFromCall)
    expect(knightType).to.equal(1)
  })

  it('should burn a knight correctly', async () => {
    let eventsKnightMinted = await SBD.KnightFacet.queryFilter('KnightMinted')
    let [knightId, knightOwner, knightType] = eventsKnightMinted[0].args
    
    let balance_before = await USDT.balanceOf(owner.address)
    await SBD.KnightFacet.burnKnight(knightId)
    let balance_after = await USDT.balanceOf(owner.address)
    let eventsKnightBurned = await SBD.KnightFacet.queryFilter('KnightBurned')
    let [knightId2, knightOwner2, knightType2] = eventsKnightBurned[0].args
    expect(knightId).to.equal(knightId2)
    expect(knightOwner).to.equal(knightOwner2)
    expect(knightType).to.equal(knightType2)
    knightOwnerFromCall = await SBD.KnightFacet.getKnightOwner(knightId)
    expect(knightOwnerFromCall).to.equal(ethers.constants.AddressZero)
    expect(balance_after - balance_before).to.equal(knightPrice.AAVE)
  })
})
