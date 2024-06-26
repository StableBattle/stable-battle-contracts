import { expect } from "chai";

import { loadFixture } from "@nomicfoundation/hardhat-network-helpers";

import { CoinInterface } from "./libraries/DataStructures";
import SBFixture, { SBFixtureInterface } from "./libraries/SBFixture";
import CoinSetup from "./libraries/CoinSetup";
import { BigNumber } from "ethers";
import { ethers } from "hardhat";
import populateClans from "../scripts/onChainTest/populateClans";

describe('ClanFacetTest', async function () {
  let SB : SBFixtureInterface;
  let Coin : CoinInterface;

  let knight : BigNumber[] = [];
  let clanId : BigNumber;
  const accounts = await ethers.getSigners();

  let knightSetup : BigNumber[] = [];
  let clanSetup : BigNumber[]= [];

  before(async function () {
    SB = await loadFixture(SBFixture);
    Coin = await loadFixture(CoinSetup);
  //await loadFixture(coinsFixture);
    const CF_setup = await populateClans();
    knightSetup = CF_setup.knightIds;
    clanSetup = CF_setup.clanIds;

    /*
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
    await SB.BEER.mint(SB.owner.address, (BigNumber.from(10).pow(await SB.BEER.decimals())).mul(1e6));
    */
  })

  describe('createClan should behave as expected', async function () {
    it('Should revert while failing ifOwnsItem check', async () => {
      await expect(SB.Diamond.ClanFacet.connect(accounts[1]).createClan(knight[0], "q")).to.be.reverted;
    })

    it('Should revert while failing ifIsKnight check', async () => {
      await SB.Diamond.GearFacet.createGear(1000, 1, "GearTest");
      await SB.Diamond.GearFacet["mintGear(uint256,uint256,address)"](1000, 1, accounts[1].address);
    
      await expect(SB.Diamond.ClanFacet.connect(accounts[1]).createClan(1000, "q")).to.be.reverted;
    })
  
    it('Should revert failing ifNotInClan check', async () => {
      await expect(SB.Diamond.ClanFacet.createClan(knightSetup[8], "qq")).to.be.reverted;
    })
  
    it('Should revert failing ifIsNotOnClanActivityCooldown check', async () => {

    })
  
    it('Should revert failing ifNotClanNameTaken check', async () => {
      await expect(SB.Diamond.ClanFacet.createClan(knight[0], "qqq")).to.be.reverted;
    })
  
    it('Should revert failing ifIsClanNameCorrectLength check', async () => {
      await expect(SB.Diamond.ClanFacet.createClan(
        knight[0],
        "TestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTest"))
      .to.be.reverted;
    })

    it('Should create a clan correctly', async () => {
      await SB.Diamond.ClanFacet.createClan(knight[0], "qqq");
      const eventsClanCreated = await SB.Diamond.ClanFacet.queryFilter(SB.Diamond.ClanFacet.filters.ClanCreated())
      const eventsKnightJoinedClan = await SB.Diamond.ClanFacet.queryFilter(SB.Diamond.ClanFacet.filters.ClanKnightJoined())
      clanId = eventsClanCreated[0].args.clanId
      expect(eventsClanCreated[0].args.knightId).to.equal(knight[0])
      
      const clanLeader = await SB.Diamond.ClanFacet.getClanLeader(clanId)
      const clanTotalMembers = await SB.Diamond.ClanFacet.getClanTotalMembers(clanId)
      const clanStake = await SB.Diamond.ClanFacet.getClanStake(clanId)
      const clanLevel = await SB.Diamond.ClanFacet.getClanLevel(clanId)
  
      expect(clanLeader).to.equal(knight[0])
      expect(clanTotalMembers).to.equal(1)
      expect(clanStake).to.equal(0)
      expect(clanLevel).to.equal(1)
  
      expect(await SB.Diamond.KnightFacet.getKnightClan(knight[0])).to.equal(clanId)
      expect(eventsKnightJoinedClan.length).to.equal(1);
      expect(eventsKnightJoinedClan[0].args.clanId).to.equal(1);
      expect(eventsKnightJoinedClan[0].args.knightId).to.equal(knight[0]);
  
      expect(await SB.Diamond.ClanFacet.getClanRole(knight[0])).to.equal(4);
    })
  })

  describe('abandonClan should behave as expected', async function () {
    it('Should revert on abandonClan with ownership error', async () => {
      await expect(SB.Diamond.ClanFacet.connect(accounts[1]).abandonClan(1, knight[0])).to.be.reverted
    })
  
    it('Should revert on abandonClan with clanLeader error', async () => {
      await SB.Diamond.ItemsFacet.safeTransferFrom(accounts[0].address, accounts[3].address, knightSetup[8], 1, "");
      await expect(SB.Diamond.ClanFacet.connect(accounts[3]).abandonClan(clanSetup[1], knightSetup[8])).to.be.reverted
    })

    it('Should abandon a clan correctly', async () => {
      SB.Diamond.ClanFacet.abandonClan(clanSetup[2], knightSetup[2]);
    })

  })

  describe('setClanRole should behave as expected', async function () {
    it('Should revert failing ifOwnsItem check', async () => {
      await expect(SB.Diamond.ClanFacet.connect(accounts[1]).setClanRole(
        clanSetup[1], 
        knightSetup[16], 
        2, 
        knightSetup[1])
      ).to.be.reverted
    })

    it('Should revert failing ifIsInClan check', async () => {
      await expect(SB.Diamond.ClanFacet.connect(accounts[1]).setClanRole(
        clanSetup[1], 
        knightSetup[6], 
        2, 
        knightSetup[1])
      ).to.be.reverted
    })

    it('Should set new clan role correctly', async () => {
      await SB.Diamond.ClanFacet.setClanRole(
        clanSetup[1], 
        knightSetup[16], 
        2, 
        knightSetup[1])
    })
  })

  describe('setClanName should behave as expected', async function () {
    it('Should revert failing ifOwnsItem check', async () => {
      await expect(SB.Diamond.ClanFacet.connect(accounts[1]).setClanName(clanId, "💩💩💩")).to.be.reverted;
    })
    
    it('Should revert failing ifNotClanNameTaken check', async () => {
      await expect(SB.Diamond.ClanFacet.setClanName(clanId, "💩💩💩")).to.be.reverted;
    })
    
    it('Should revert failing ifIsClanNameCorrectLength check', async () => {
      await expect(SB.Diamond.ClanFacet.setClanName(
        clanId, 
        "0000000000000000000000000000000000000000000000000000000000000000000000000000000")
      ).to.be.reverted;
    })

    it('Should change clan name correctly', async () => {
      SB.Diamond.ClanFacet.setClanName(
        clanId, 
        "newName");
    })
  })

  describe('clanStake should behave as expected', async function () {
    it('Should revert failing ifClanExists', async () => {
      SB.BEER.mint(accounts[1].address, 1000);
      await expect(SB.Diamond.ClanFacet.clanStake(clanSetup[3], 1000)).to.be.reverted;
    })

    it('Should stake in clan correctly', async () => {
      SB.Diamond.ClanFacet.clanStake(clanSetup[2], 1000);
      //Add event check & internal value check
    })
  })

  describe('clanWithdrawRequest should behave as expected', async function () {
    
  })

  describe('clanWithdraw should behave as expected', async function () {

  })

  describe('joinClan should behave as expected', async function () {

  })

  describe('withdrawJoinClan should behave as expected', async function () {

  })

  describe('leaveClan should behave as expected', async function () {

  })

  describe('kickFromClan should behave as expected', async function () {

  })

  describe('approveJoinClan should behave as expected', async function () {

  })

  describe('dismissJoinClan should behave as expected', async function () {

  })
  
  it('Should stake & level up a clan correctly', async () => {
    const amount = (BigNumber.from(10).pow(await SB.BEER.decimals())).mul(150000);
    await SB.Diamond.ClanFacet.clanStake(clanId, amount);

    const eventsStakeAdded = await SB.Diamond.ClanFacet.queryFilter(SB.Diamond.ClanFacet.filters.ClanStakeAdded());
    expect(eventsStakeAdded[0].args.user).to.equal(SB.owner.address);
    expect(eventsStakeAdded[0].args.clanId).to.equal(clanId);
    expect(eventsStakeAdded[0].args.amount).to.equal(amount);

    const eventsClanNewLevel = await SB.Diamond.ClanFacet.queryFilter(SB.Diamond.ClanFacet.filters.ClanNewLevel());
    expect(eventsClanNewLevel[0].args.clanId).to.equal(clanId);
    expect(eventsClanNewLevel[0].args.newLevel).to.equal(1);

    expect(await SB.Diamond.ClanFacet.getStakeOf(clanId, SB.owner.address)).to.equal(amount);
    expect(await SB.Diamond.ClanFacet.getClanLevel(clanId)).to.equal(3);
  })

  it('Should withdraw & level down a clan correctly', async () => {
    const amount = (BigNumber.from(10).pow(await SB.BEER.decimals())).mul(50000);
    await SB.Diamond.ClanFacet.clanWithdrawRequest(clanId, amount);
    await SB.Diamond.ClanFacet.clanWithdraw(clanId, amount);

    const eventsStakeWithdrawn = await SB.Diamond.ClanFacet.queryFilter(SB.Diamond.ClanFacet.filters.ClanStakeWithdrawn())
    expect(eventsStakeWithdrawn[0].args.user).to.equal(SB.owner.address)
    expect(eventsStakeWithdrawn[0].args.clanId).to.equal(clanId)
    expect(eventsStakeWithdrawn[0].args.amount).to.equal(amount)

    const eventsClanNewLevel = await SB.Diamond.ClanFacet.queryFilter(SB.Diamond.ClanFacet.filters.ClanNewLevel())
    expect(eventsClanNewLevel[0].args.clanId).to.equal(clanId);
    expect(eventsClanNewLevel[0].args.newLevel).to.equal(2);

    expect(await SB.Diamond.ClanFacet.getStakeOf(clanId, SB.owner.address)).to.equal((BigNumber.from(10).pow(await SB.BEER.decimals())).mul(100000))
    expect(await SB.Diamond.ClanFacet.getClanLevel(clanId)).to.equal(1)
  })

  it('Should revert on joinClan with wrongKnightId error', async () => {
    await expect(SB.Diamond.ClanFacet.joinClan(1, clanId)).to.be.reverted;
  })

  it('Should revert on joinClan with ownership error', async () => {
    await expect(SB.Diamond.ClanFacet.joinClan(knight[1], clanId)).to.be.reverted;
  })

  it('Should revert on joinClan with alreadyinclan error', async () => {
    await expect(SB.Diamond.ClanFacet.joinClan(knightSetup[8], clanId)).to.be.reverted;
  })

  it('Should revert on joinClan with clannotexist error', async () => {
    await expect(SB.Diamond.ClanFacet.joinClan(knightSetup[8], 100)).to.be.reverted;
  })

  it('Should allow user1 & user2 to create a join proposals', async () => {
    await SB.Diamond.ClanFacet.connect(SB.users[1]).joinClan(knight[1], clanId)
    await SB.Diamond.ClanFacet.connect(SB.users[2]).joinClan(knight[2], clanId)
    const eventsKnightAskedToJoin = await SB.Diamond.ClanFacet.queryFilter(SB.Diamond.ClanFacet.filters.ClanJoinProposalSent())
    
    expect(eventsKnightAskedToJoin.length).to.equal(2);
    
    expect(eventsKnightAskedToJoin[0].args.clanId).to.equal(clanId)
    expect(eventsKnightAskedToJoin[0].args.knightId).to.equal(knight[1])
    expect(await SB.Diamond.ClanFacet.getClanJoinProposal(knight[1])).to.equal(clanId)

    expect(eventsKnightAskedToJoin[1].args.clanId).to.equal(clanId)
    expect(eventsKnightAskedToJoin[1].args.knightId).to.equal(knight[2])
    expect(await SB.Diamond.ClanFacet.getClanJoinProposal(knight[2])).to.equal(clanId)
  })

  it('Should accept user1', async () => {
    await SB.Diamond.ClanFacet.approveJoinClan(knight[1], clanId, knight[0]);
    const eventsKnightJoinedClan = await SB.Diamond.ClanFacet.queryFilter(SB.Diamond.ClanFacet.filters.ClanKnightJoined());
    expect(eventsKnightJoinedClan.length).to.equal(2);
    expect(await SB.Diamond.ClanFacet.getClanTotalMembers(clanId)).to.deep.equal(BigNumber.from(2));
    expect(await SB.Diamond.KnightFacet.getKnightClan(knight[1])).to.equal(clanId)

    await SB.Diamond.ClanFacet.leaveClan(knight[2], clanId);
    await SB.Diamond.ClanFacet.joinClan(knight[2], clanId);
  })

  it('Should dismiss user2', async () => {
    await SB.Diamond.ClanFacet.dismissJoinClan(knight[2], clanId, knight[0]);
    const eventsKnightJoinedClan = await SB.Diamond.ClanFacet.queryFilter(SB.Diamond.ClanFacet.filters.ClanJoinProposalDismissed());
    expect(eventsKnightJoinedClan.length).to.equal(1);
    expect(await SB.Diamond.ClanFacet.getClanTotalMembers(clanId)).to.deep.equal(BigNumber.from(2));
    expect(await SB.Diamond.KnightFacet.getKnightClan(knight[2])).to.equal(0)
  })

  it('Should assign user1 an admin role', async () => {
    await SB.Diamond.ClanFacet.setClanRole(clanId, knight[1], 2, knight[0]);
    
    const knightRole = (await SB.Diamond.ClanFacet.getClanKnightInfo(knight[1]))[2];
    expect(knightRole).to.equal(2);
  })

  it('Should kick user1', async () => {
    await SB.Diamond.ClanFacet.kickFromClan(knight[1], clanId, knight[0]);
    const eventsClanNewName = await SB.Diamond.ClanFacet.queryFilter(SB.Diamond.ClanFacet.filters.ClanKnightKicked());
    expect(eventsClanNewName[0].args.callerId).to.equal(knight[0]);
  })

  it('Should rename clan', async () => {
    await SB.Diamond.ClanFacet.setClanName(1, "pook");
    const eventsClanNewName = await SB.Diamond.ClanFacet.queryFilter(SB.Diamond.ClanFacet.filters.ClanNewName());
    eventsClanNewName[0].args
  })
})
