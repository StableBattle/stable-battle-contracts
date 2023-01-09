import hre from "hardhat";
import { expect } from "chai";
import "@nomicfoundation/hardhat-chai-matchers";
import { loadFixture } from "@nomicfoundation/hardhat-network-helpers";

import { COIN, CoinInterface, POOL } from "./libraries/DataStructures";
import SBFixture, { SBFixtureInterface } from "./libraries/SBFixture";
import CoinSetup from "./libraries/CoinSetup";
import { BigNumber } from "ethers";
import coinsFixture from "./libraries/coinsFixture";

describe('TreasuryFacetTest', async function () {

  let SB : SBFixtureInterface;
  let Coin : CoinInterface;
  let knight : BigNumber[] = [];
  let clanId : BigNumber;

  before(async () => {
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

    await SB.Diamond.ClanFacet.create(knight[0])
    let eventsClanCreated = await SB.Diamond.ClanFacet.queryFilter(SB.Diamond.ClanFacet.filters.ClanCreated())
    clanId = eventsClanCreated[0].args.clanId
  })

  it('Should update CastleHolder correctly', async () => {
    expect(await SB.Diamond.TournamentFacet.getCastleHolderClan()).to.equal(0)
    await SB.Diamond.TournamentFacet.updateCastleOwnership(clanId)
    let eventsCastleHolderChanged = await SB.Diamond.TournamentFacet.queryFilter(SB.Diamond.TournamentFacet.filters.CastleHolderChanged())
    expect(eventsCastleHolderChanged[0].args.clanId).to.equal(clanId)
    expect(await SB.Diamond.TournamentFacet.getCastleHolderClan()).to.equal(clanId)
  })

  it('Should correctly update SB info after mint', async () => {
    expect(await SB.SBV.balanceOf(SB.owner.address)).to.equal(0)
    await SB.SBV.adminMint(SB.owner.address, 0)
    expect(await SB.SBV.balanceOf(SB.owner.address)).to.equal(1)
    let eventsTransfer = await SB.SBV.queryFilter(SB.SBV.filters.Transfer())
    expect(eventsTransfer[0].args.from).to.equal(hre.ethers.constants.AddressZero)
    expect(eventsTransfer[0].args.to).to.equal(SB.owner.address)
    expect(eventsTransfer[0].args.tokenId).equal(0)
    let eventsVillageInfoUpdated = await SB.Diamond.SBVHookFacet.queryFilter(SB.Diamond.SBVHookFacet.filters.VillageInfoUpdated())
    expect(eventsVillageInfoUpdated[0].args.id).to.equal(0)
    expect(eventsVillageInfoUpdated[0].args.newOwner).to.equal(SB.owner.address)
    expect(eventsVillageInfoUpdated[0].args.villageAmount).to.equal(1)
  })

  it('Should correctly update SB info after transfer', async () => {
    await SB.SBV.transferFrom(SB.owner.address, SB.users[1].address, 0)
    let eventsVillageInfoUpdated = await SB.Diamond.SBVHookFacet.queryFilter(SB.Diamond.SBVHookFacet.filters.VillageInfoUpdated())
    expect(eventsVillageInfoUpdated[1].args.id).to.equal(0)
    expect(eventsVillageInfoUpdated[1].args.newOwner).to.equal(SB.users[1].address)
    expect(eventsVillageInfoUpdated[1].args.villageAmount).to.equal(1)
  })

  it('Should assign correct amount of SBT rewards based on village & castle ownership', async () => {
    let tax = await SB.Diamond.TreasuryFacet.getCastleTax()
    let rewardPerBlock = await SB.Diamond.TreasuryFacet.getRewardPerBlock()
    let user1BalanceBefore = await SB.SBT.balanceOf(SB.users[1].address)
    let ownerBalanceBefore = await SB.SBT.balanceOf(SB.owner.address)
    await SB.Diamond.TreasuryFacet.claimRewards()
    let user1BalanceAfter = await SB.SBT.balanceOf(SB.users[1].address)
    let ownerBalanceAfter = await SB.SBT.balanceOf(SB.owner.address)
    let realVillageReward = user1BalanceAfter.sub(user1BalanceBefore)
    let realCastleReward = ownerBalanceAfter.sub(ownerBalanceBefore)
  //console.log("realVillageReward: ", realVillageReward)
  //console.log("realCastleReward: ", realCastleReward)
    const lastBlock = await hre.ethers.provider.getBlock("latest")
    let paymentCycles = lastBlock.number - SB.predeployBlock
  //console.log("calcpaymentCycles: ", paymentCycles)
    let calcVillageReward = paymentCycles * rewardPerBlock.toNumber() * (100 - tax.toNumber())
  //console.log("calcVillageReward: ", calcVillageReward)
    let calcCastleReward = paymentCycles * rewardPerBlock.toNumber() * tax.toNumber()
  //console.log("calcCastleReward: ", calcCastleReward)
    expect(realCastleReward).to.equal(calcCastleReward)
    expect(realVillageReward).to.equal(calcVillageReward)
  })
})
