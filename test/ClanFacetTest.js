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

describe('ClanFacetTest', async function () {
  let USDT_address = ethers.utils.getAddress("0x21C561e551638401b937b03fE5a0a0652B99B7DD")
  let AAVE_address = ethers.utils.getAddress("0x6C9fB0D5bD9429eb9Cd96B85B81d872281771E6B")
  let knightPrice = { USDT: 1e9, USDC: 1e9, TEST: 0}
  let owner
  let user1
  let KnightFacet1
  let ClanFacet1
  let user2
  let KnightFacet2
  let ClanFacet2
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
    await USDT.mint(knightPrice.USDT * 10)
    await USDT.approve(SBD.Address, knightPrice.USDT)
    await SBD.KnightFacet.mintKnight(1, 1)
    KnightFacet1 = SBD.KnightFacet.connect(user1)
    ClanFacet1 = SBD.ClanFacet.connect(user1)
    KnightFacet2 = SBD.KnightFacet.connect(user2)   
    ClanFacet2 = SBD.ClanFacet.connect(user2) 
    await KnightFacet1.mintKnight(2, 3)
    await KnightFacet2.mintKnight(2, 3)

    let eventsKnightMinted = await SBD.KnightFacet.queryFilter('KnightMinted')
    knightId = eventsKnightMinted[0].args.knightId
    knightIdUser1 = eventsKnightMinted[1].args.knightId
    knightIdUser2 = eventsKnightMinted[2].args.knightId
  })

  it('Should create a clan correctly', async () => {
    await SBD.ClanFacet.create(knightId)
    let eventsClanCreated = await SBD.ClanFacet.queryFilter('ClanCreated')
    clanId = eventsClanCreated[0].args.clanId
    expect(eventsClanCreated[0].args.knightId).to.be.equal(knightId)
    
    let clanLeader = await SBD.ClanFacet.getClanLeader(clanId)
    let clanTotalMembers = await SBD.ClanFacet.getClanTotalMembers(clanId)
    let clanStake = await SBD.ClanFacet.getClanStake(clanId)
    let clanLevel = await SBD.ClanFacet.getClanLevel(clanId)

    expect(knightId).to.equal(knightId)
    expect(clanLeader).to.equal(knightId)
    expect(clanTotalMembers).to.equal(1)
    expect(clanStake).to.equal(0)
    expect(clanLevel).to.equal(0)

    expect(await SBD.KnightFacet.getKnightClan(knightId)).to.equal(clanId)
  })

  it('Should stake & level up a clan correctly', async () => {
    await SBT.SBTFacet.stake(clanId, 650)
    let eventsStake = await SBT.SBTFacet.queryFilter('Stake')
    expect(eventsStake[0].args.benefactor).to.equal(owner.address)
    expect(eventsStake[0].args.clanId).to.equal(clanId)
    expect(eventsStake[0].args.amount).to.equal(650)

    let eventsStakeAdded = await SBD.ClanFacet.queryFilter('StakeAdded')
    expect(eventsStakeAdded[0].args.benefactor).to.equal(owner.address)
    expect(eventsStakeAdded[0].args.clanId).to.equal(clanId)
    expect(eventsStakeAdded[0].args.amount).to.equal(650)

    let eventsClanLeveledUp = await SBD.ClanFacet.queryFilter('ClanLeveledUp')
    expect(eventsClanLeveledUp[0].args.clanId).to.equal(clanId)
    expect(eventsClanLeveledUp[0].args.newLevel).to.equal(7)

    expect(await SBD.ClanFacet.getStakeOf(owner.address, clanId)).to.equal(650)
    expect(await SBD.ClanFacet.getClanLevel(clanId)).to.equal(7)
  })

  it('Should withdraw & level down a clan correctly', async () => {
    await SBT.SBTFacet.withdraw(clanId, 210)
    let eventsWithdraw = await SBT.SBTFacet.queryFilter('Withdraw')
    expect(eventsWithdraw[0].args.benefactor).to.equal(owner.address)
    expect(eventsWithdraw[0].args.clanId).to.equal(clanId)
    expect(eventsWithdraw[0].args.amount).to.equal(210)

    let eventsStakeWithdrawn = await SBD.ClanFacet.queryFilter('StakeWithdrawn')
    expect(eventsStakeWithdrawn[0].args.benefactor).to.equal(owner.address)
    expect(eventsStakeWithdrawn[0].args.clanId).to.equal(clanId)
    expect(eventsStakeWithdrawn[0].args.amount).to.equal(210)

    let eventsClanLeveledDown = await SBD.ClanFacet.queryFilter('ClanLeveledDown')
    expect(eventsClanLeveledDown[0].args.clanId).to.equal(clanId)
    expect(eventsClanLeveledDown[0].args.newLevel).to.equal(5)

    expect(await SBD.ClanFacet.getStakeOf(owner.address, clanId)).to.equal(440)
    expect(await SBD.ClanFacet.getClanLevel(clanId)).to.equal(5)
  })

  it('Should allow user1 & user2 to create a join proposals', async () => {
    await ClanFacet1.join(knightIdUser1, clanId)
    await ClanFacet2.join(knightIdUser2, clanId)
    let eventsKnightAskedToJoin = await SBD.ClanFacet.queryFilter('KnightAskedToJoin')
    
    expect(eventsKnightAskedToJoin[0].args.clanId).to.equal(clanId)
    expect(eventsKnightAskedToJoin[0].args.knightId).to.equal(knightIdUser1)
    expect(await SBD.ClanFacet.getProposal(knightIdUser1, clanId)).to.equal(1)

    expect(eventsKnightAskedToJoin[1].args.clanId).to.equal(clanId)
    expect(eventsKnightAskedToJoin[1].args.knightId).to.equal(knightIdUser2)
    expect(await SBD.ClanFacet.getProposal(knightIdUser2, clanId)).to.equal(1)
  })

  it('Should accept user1', async () => {
    await SBD.ClanFacet.invite(knightIdUser1, clanId)
    let eventsKnightJoinedClan = await SBD.ClanFacet.queryFilter('KnightJoinedClan')
    expect(eventsKnightJoinedClan[0].args.clanId).to.equal(clanId)
    expect(eventsKnightJoinedClan[0].args.knightId).to.equal(knightIdUser1)
    expect(await SBD.ClanFacet.getClanTotalMembers(clanId)).to.equal(2)
    expect(await SBD.KnightFacet.getKnightClan(knightIdUser1)).to.equal(clanId)
  })

  it('Should abandon a clan correctly', async () => {
    await SBD.ClanFacet.abandon(clanId)
    
    let clanLeader = await SBD.ClanFacet.getClanLeader(clanId)

    expect(clanLeader).to.equal(0)
    expect(await SBD.KnightFacet.getKnightClan(knightId)).to.equal(0)
  })

})
