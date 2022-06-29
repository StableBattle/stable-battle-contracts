/* global describe it before ethers */

const {
  getSelectors,
  FacetCutAction,
  removeSelectors,
  findAddressPositionInFacets
} = require('../scripts/libraries/diamond.js')

const { deployStableBattle } = require('../scripts/deploy.js')

const { expect } = require('chai')
const { ethers } = require('hardhat')

describe('TreasuryFacetTest', async function () {
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

  let knightId
  let clanId
  let predeployBlock
  //const addresses = []

  before(async function () {
    [owner, user1, user2] = await ethers.getSigners()
    USDT = await ethers.getContractAt('IERC20Mintable', USDT_address)
    AAVE = await ethers.getContractAt('IPool', AAVE_address)
    predeployBlock = await hre.ethers.provider.getBlock("latest")
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
    await USDT.mint(knightPrice.AAVE * 10)
    await USDT.approve(SBD.Address, knightPrice.AAVE)
    await SBD.KnightFacet.mintKnight(0)

    let eventsKnightMinted = await SBD.KnightFacet.queryFilter('KnightMinted')
    knightId = eventsKnightMinted[0].args.knightId

    await SBD.ClanFacet.create(knightId)
    let eventsClanCreated = await SBD.ClanFacet.queryFilter('ClanCreated')
    clanId = eventsClanCreated[0].args.clanId
  })

  it('Should update CastleHolder correctly', async () => {
    expect(await SBD.TournamentFacet.castleHolder()).to.equal(0)
    await SBD.TournamentFacet.updateCastleOwnership(clanId)
    let eventsCastleHolderChanged = await SBD.TournamentFacet.queryFilter('CastleHolderChanged')
    expect(eventsCastleHolderChanged[0].args.clanId).to.equal(clanId)
    expect(await SBD.TournamentFacet.castleHolder()).to.equal(clanId)
  })

  it('Should correctly update SB info after mint', async () => {
    expect(await SBV.SBVFacet.balanceOf(owner.address)).to.equal(0)
    await SBV.SBVFacet.adminMint(owner.address)
    expect(await SBV.SBVFacet.balanceOf(owner.address)).to.equal(1)
    let eventsTransfer = await SBV.SBVFacet.queryFilter('Transfer')
    expect(eventsTransfer[0].args.from).to.equal(ethers.constants.AddressZero)
    expect(eventsTransfer[0].args.to).to.equal(owner.address)
    expect(eventsTransfer[0].args.tokenId).equal(0)
    let eventsVillageInfoUpdated = await SBD.SBVHookFacet.queryFilter('VillageInfoUpdated')
    expect(eventsVillageInfoUpdated[0].args.id).to.equal(0)
    expect(eventsVillageInfoUpdated[0].args.newOwner).to.equal(owner.address)
    expect(eventsVillageInfoUpdated[0].args.villageAmount).to.equal(1)
  })

  it('Should correctly update SB info after transfer', async () => {
    await SBV.SBVFacet.transferFrom(owner.address, user1.address, 0)
    let eventsVillageInfoUpdated = await SBD.SBVHookFacet.queryFilter('VillageInfoUpdated')
    expect(eventsVillageInfoUpdated[1].args.id).to.equal(0)
    expect(eventsVillageInfoUpdated[1].args.newOwner).to.equal(user1.address)
    expect(eventsVillageInfoUpdated[1].args.villageAmount).to.equal(1)
  })

  it('Should assign correct amount of SBT rewards based on village & castle ownership', async () => {
    let tax = await SBD.TreasuryFacet.getTax()
    let rewardPerBlock = await SBD.TreasuryFacet.getRewardPerBlock()
    let user1BalanceBefore = await SBT.SBTFacet.balanceOf(user1.address)
    let ownerBalanceBefore = await SBT.SBTFacet.balanceOf(owner.address)

    await SBD.TreasuryFacet.claimRewards()
    let user1BalanceAfter = await SBT.SBTFacet.balanceOf(user1.address)
    let ownerBalanceAfter = await SBT.SBTFacet.balanceOf(owner.address)
    console.log("realVillageReward: ", user1BalanceAfter - user1BalanceBefore)
    console.log("realCastleReward: ", ownerBalanceAfter - ownerBalanceBefore)
    const lastBlock = await hre.ethers.provider.getBlock("latest")
    let paymentCycles = lastBlock.number - predeployBlock.number
    console.log("calcpaymentCycles: ", paymentCycles)
    let calcVillageReward = paymentCycles * rewardPerBlock * (100 - tax)
    console.log("calcVillageReward: ", calcVillageReward)
    let calcCastleReward = paymentCycles * rewardPerBlock * (tax)
    console.log("calcCastleReward: ", calcCastleReward)
  })
})
