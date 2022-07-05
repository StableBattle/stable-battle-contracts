/* global describe it before ethers */

const {
  getSelectors,
  FacetCutAction,
  removeSelectors,
  findAddressPositionInFacets
} = require('../scripts/libraries/diamond.js')

const { deployStableBattle } = require('../scripts/deploy.js')

const { assert, expect } = require('chai')

describe('StableBattleTest', async function () {
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

  it('should have correct number of facets -- call to facetAddresses function', async () => {
    for (const address of await SBD.LoupeFacet.facetAddresses()){ SBD.addresses.push(address) }
    for (const address of await SBT.LoupeFacet.facetAddresses()){ SBT.addresses.push(address) }
    for (const address of await SBV.LoupeFacet.facetAddresses()){ SBV.addresses.push(address) }

    assert.equal(SBD.addresses.length, 11)
    assert.equal(SBT.addresses.length, 4)
    assert.equal(SBV.addresses.length, 4)
  })

  it('SBD facets should have the right function selectors -- call to facetFunctionSelectors function', async () => {
    let selectors = getSelectors(SBD.CutFacet)
    result = await SBD.LoupeFacet.facetFunctionSelectors(SBD.addresses[0])
    assert.sameMembers(result, selectors)
    selectors = getSelectors(SBD.LoupeFacet)
    result = await SBD.LoupeFacet.facetFunctionSelectors(SBD.addresses[1])
    assert.sameMembers(result, selectors)
    selectors = getSelectors(SBD.OwnershipFacet)
    result = await SBD.LoupeFacet.facetFunctionSelectors(SBD.addresses[2])
    assert.sameMembers(result, selectors)

    let items_selectors = getSelectors(SBD.ItemsFacet)
    result = await SBD.LoupeFacet.facetFunctionSelectors(SBD.addresses[3])
    assert.sameMembers(result, items_selectors)
    selectors = getSelectors(SBD.ClanFacet)
    result = await SBD.LoupeFacet.facetFunctionSelectors(SBD.addresses[4])
    assert.sameMembers(result, selectors)
    /*
    selectors = getSelectors(SBD.ForgeFacet)
    selectors.filter(selector => !(items_selectors.findIndex(selector) >= 0))
    result = await SBD.LoupeFacet.facetFunctionSelectors(SBD.addresses[5])
    assert.sameMembers(result, selectors)
    selectors = getSelectors(SBD.KnightFacet)
    selectors.filter(selector => !(items_selectors.findIndex(selector) >= 0))
    result = await SBD.LoupeFacet.facetFunctionSelectors(SBD.addresses[6])
    assert.sameMembers(result, selectors)
    */
    selectors = getSelectors(SBD.SBVHookFacet)
    result = await SBD.LoupeFacet.facetFunctionSelectors(SBD.addresses[7])
    assert.sameMembers(result, selectors)
    selectors = getSelectors(SBD.TournamentFacet)
    result = await SBD.LoupeFacet.facetFunctionSelectors(SBD.addresses[8])
    assert.sameMembers(result, selectors)
    selectors = getSelectors(SBD.TreasuryFacet)
    result = await SBD.LoupeFacet.facetFunctionSelectors(SBD.addresses[9])
    assert.sameMembers(result, selectors)
  })
  
  it('SBT facets should have the right function selectors -- call to facetFunctionSelectors function', async () => {
    let selectors = getSelectors(SBT.CutFacet)
    result = await SBT.LoupeFacet.facetFunctionSelectors(SBT.addresses[0])
    assert.sameMembers(result, selectors)
    selectors = getSelectors(SBT.LoupeFacet)
    result = await SBT.LoupeFacet.facetFunctionSelectors(SBT.addresses[1])
    assert.sameMembers(result, selectors)
    selectors = getSelectors(SBT.OwnershipFacet)
    result = await SBT.LoupeFacet.facetFunctionSelectors(SBT.addresses[2])
    assert.sameMembers(result, selectors)

    selectors = getSelectors(SBT.SBTFacet)
    result = await SBT.LoupeFacet.facetFunctionSelectors(SBT.addresses[3])
    assert.sameMembers(result, selectors)
  })
  
  it('SBV facets should have the right function selectors -- call to facetFunctionSelectors function', async () => {
    let selectors = getSelectors(SBV.CutFacet)
    result = await SBV.LoupeFacet.facetFunctionSelectors(SBV.addresses[0])
    assert.sameMembers(result, selectors)
    selectors = getSelectors(SBV.LoupeFacet)
    result = await SBV.LoupeFacet.facetFunctionSelectors(SBV.addresses[1])
    assert.sameMembers(result, selectors)
    selectors = getSelectors(SBV.OwnershipFacet)
    result = await SBV.LoupeFacet.facetFunctionSelectors(SBV.addresses[2])
    assert.sameMembers(result, selectors)

    selectors = getSelectors(SBV.SBVFacet)
    result = await SBV.LoupeFacet.facetFunctionSelectors(SBV.addresses[3])
    //assert.sameMembers(result, selectors)
  })
/*
  it('should create and level up a clan', async () => {
    let id = await SBD.KnightFacet.mintKnight()
    let clan = await SBD.ClanFacet.Create(id)
    await SBT.SBTFacet.stake(clan, 250)
    let level = await SBD.ClanFacet.clanLevelOf(clan)
    assert.equal(level, 3)
  })
*/
/*
  it('selectors should be associated to facets correctly -- multiple calls to facetAddress function', async () => {
    assert.equal(
      addresses[0],
      await diamondLoupeFacet.facetAddress('0x1f931c1c')
    )
    assert.equal(
      addresses[1],
      await diamondLoupeFacet.facetAddress('0xcdffacc6')
    )
    assert.equal(
      addresses[1],
      await diamondLoupeFacet.facetAddress('0x01ffc9a7')
    )
    assert.equal(
      addresses[2],
      await diamondLoupeFacet.facetAddress('0xf2fde38b')
    )
  })
*/
})
