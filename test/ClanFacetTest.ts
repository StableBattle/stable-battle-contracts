import { expect } from "chai";
import "@nomicfoundation/hardhat-chai-matchers";
import { loadFixture } from "@nomicfoundation/hardhat-network-helpers";

import { POOL, COIN, CoinInterface } from "./libraries/DataStructures";
import SBFixture, { SBFixtureInterface } from "./libraries/SBFixture";
import CoinSetup from "./libraries/CoinSetup";
import { BigNumber } from "ethers";
import coinsFixture from "./libraries/coinsFixture";

describe('ClanFacetTest', async function () {
  let SB : SBFixtureInterface;
  let Coin : CoinInterface;

  let knight : BigNumber[] = [];
  let clanId : BigNumber;

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

  it('Should create a clan correctly', async () => {
    await SB.Diamond.ClanFacet.createClan(knight[0])
    const eventsClanCreated = await SB.Diamond.ClanFacet.queryFilter(SB.Diamond.ClanFacet.filters.ClanCreated())
    clanId = eventsClanCreated[0].args.clanId
    expect(eventsClanCreated[0].args.knightId).to.equal(knight[0])
    
    const clanLeader = await SB.Diamond.ClanFacet.getClanLeader(clanId)
    const clanTotalMembers = await SB.Diamond.ClanFacet.getClanTotalMembers(clanId)
    const clanStake = await SB.Diamond.ClanFacet.getClanStake(clanId)
    const clanLevel = await SB.Diamond.ClanFacet.getClanLevel(clanId)

    expect(knight[0]).to.equal(knight[0])
    expect(clanLeader).to.equal(knight[0])
    expect(clanTotalMembers).to.equal(1)
    expect(clanStake).to.equal(0)
    expect(clanLevel).to.equal(0)

    expect(await SB.Diamond.KnightFacet.getKnightClan(knight[0])).to.equal(clanId)
  })

  it('Should stake & level up a clan correctly', async () => {
    await SB.SBT.stake(clanId, 650)
    const eventsStake = await SB.SBT.queryFilter(SB.SBT.filters.Stake())
    expect(eventsStake[0].args.sender).to.equal(SB.owner.address)
    expect(eventsStake[0].args.clanId).to.equal(clanId)
    expect(eventsStake[0].args.amount).to.equal(650)

    const eventsStakeAdded = await SB.Diamond.ClanFacet.queryFilter(SB.Diamond.ClanFacet.filters.StakeAdded())
    expect(eventsStakeAdded[0].args.benefactor).to.equal(SB.owner.address)
    expect(eventsStakeAdded[0].args.clanId).to.equal(clanId)
    expect(eventsStakeAdded[0].args.amount).to.equal(650)

    const eventsClanLeveledUp = await SB.Diamond.ClanFacet.queryFilter(SB.Diamond.ClanFacet.filters.ClanLeveledUp())
    expect(eventsClanLeveledUp[0].args.clanId).to.equal(clanId)
    expect(eventsClanLeveledUp[0].args.newLevel).to.equal(7)

    expect(await SB.Diamond.ClanFacet.getStakeOf(SB.owner.address, clanId)).to.equal(650)
    expect(await SB.Diamond.ClanFacet.getClanLevel(clanId)).to.equal(7)
  })

  it('Should withdraw & level down a clan correctly', async () => {
    await SB.SBT.withdraw(clanId, 210)
    const eventsWithdraw = await SB.SBT.queryFilter(SB.SBT.filters.Withdraw());
    expect(eventsWithdraw[0].args.sender).to.equal(SB.owner.address)
    expect(eventsWithdraw[0].args.clanId).to.equal(clanId)
    expect(eventsWithdraw[0].args.amount).to.equal(210)

    const eventsStakeWithdrawn = await SB.Diamond.ClanFacet.queryFilter(SB.Diamond.ClanFacet.filters.StakeWithdrawn())
    expect(eventsStakeWithdrawn[0].args.benefactor).to.equal(SB.owner.address)
    expect(eventsStakeWithdrawn[0].args.clanId).to.equal(clanId)
    expect(eventsStakeWithdrawn[0].args.amount).to.equal(210)

    const eventsClanLeveledDown = await SB.Diamond.ClanFacet.queryFilter(SB.Diamond.ClanFacet.filters.ClanLeveledDown())
    expect(eventsClanLeveledDown[0].args.clanId).to.equal(clanId)
    expect(eventsClanLeveledDown[0].args.newLevel).to.equal(5)

    expect(await SB.Diamond.ClanFacet.getStakeOf(SB.owner.address, clanId)).to.equal(440)
    expect(await SB.Diamond.ClanFacet.getClanLevel(clanId)).to.equal(5)
  })

  it('Should allow user1 & user2 to create a join proposals', async () => {
    await SB.Diamond.ClanFacet.connect(SB.users[1]).join(knight[1], clanId)
    await SB.Diamond.ClanFacet.connect(SB.users[2]).join(knight[2], clanId)
    const eventsKnightAskedToJoin = await SB.Diamond.ClanFacet.queryFilter(SB.Diamond.ClanFacet.filters.KnightAskedToJoin())
    
    expect(eventsKnightAskedToJoin[0].args.clanId).to.equal(clanId)
    expect(eventsKnightAskedToJoin[0].args.knightId).to.equal(knight[1])
    expect(await SB.Diamond.ClanFacet.getClanJoinProposal(knight[1])).to.equal(clanId)

    expect(eventsKnightAskedToJoin[1].args.clanId).to.equal(clanId)
    expect(eventsKnightAskedToJoin[1].args.knightId).to.equal(knight[2])
    expect(await SB.Diamond.ClanFacet.getClanJoinProposal(knight[2])).to.equal(clanId)
  })

  it('Should accept user1', async () => {
    await SB.Diamond.ClanFacet.approveJoinClan(knight[1], clanId, knight[0])
    const eventsKnightJoinedClan = await SB.Diamond.ClanFacet.queryFilter(SB.Diamond.ClanFacet.filters.KnightJoinedClan())
    expect(eventsKnightJoinedClan.length).to.equal(2);
    expect(eventsKnightJoinedClan[1].args.clanId).to.equal(clanId)
    expect(eventsKnightJoinedClan[1].args.knightId).to.equal(knight[1])
    console.log(await SB.Diamond.ClanFacet.getClanTotalMembers(clanId));
    expect(await SB.Diamond.ClanFacet.getClanTotalMembers(clanId)).to.equal(BigNumber.from(2));
    expect(await SB.Diamond.KnightFacet.getKnightClan(knight[1])).to.equal(clanId)
  })
})
