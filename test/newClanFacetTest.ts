import hre from "hardhat";
import deployStableBattle from "../scripts/deployStableBattle";
import { IStableBattle } from "../typechain-types"
import { expect } from "chai";
import { SBD } from "../scripts/config/hardhat/main-contracts"
import populateClans from "../scripts/onChainTest/populateClans";
import { BigNumber } from "ethers";

describe('ClanFacetTest', async function () {
  let StableBattle : IStableBattle;
  let clanIds : BigNumber[];
  let knightIds : BigNumber[];
  
  before(async function () {
    await deployStableBattle();
    StableBattle = await hre.ethers.getContractAt("IStableBattle", SBD);
    ({clanIds, knightIds} = await populateClans());
  });

  it('should join, leave, join a clan', async function () {
    StableBattle.joinClan(clanIds[2], knightIds[32]);
    StableBattle.approveJoinClan(clanIds[2], knightIds[32], knightIds[2]);
    StableBattle.leaveClan(clanIds[2], knightIds[32]);
    StableBattle.joinClan(clanIds[2], knightIds[32]);
    StableBattle.approveJoinClan(clanIds[2], knightIds[32], knightIds[2]);
    StableBattle.leaveClan(clanIds[2], knightIds[32]);
  });
})