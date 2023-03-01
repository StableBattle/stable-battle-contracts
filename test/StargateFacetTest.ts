import hre from "hardhat";
import { expect } from "chai";
import "@nomicfoundation/hardhat-chai-matchers";
import { loadFixture } from "@nomicfoundation/hardhat-network-helpers";

import { COIN, CoinInterface } from "./libraries/DataStructures";
import SBFixture, { SBFixtureInterface } from "./libraries/SBFixture";
import CoinSetup from "./libraries/CoinSetup";
import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";

describe('StargateFacetTest', async function () {

  let SB : SBFixtureInterface;
  let Coin : CoinInterface;

  before(async () => {
    SB = await loadFixture(SBFixture);
    Coin = await loadFixture(CoinSetup);

    //Deposit 1000 USDT into contract
    const wealthyAccount = await hre.ethers.getSigner("0x47ac0Fb4F2D84898e4D9E7b4DaB3C24507a6D503");
    Coin.USDT.connect(wealthyAccount).transfer(SB.Diamond.Address, 1e9);
  });

  it('Should put 1000 USDT into Stargate', async () => {
    const StargateFacet = await hre.ethers.getContractAt("IStargate", SB.Diamond.Address);
    StargateFacet.stakeToStargate(COIN.USDT, 1e9);
  });

  it('Should withdraw 1000 USDT from Stargate', async () => {
    const StargateFacet = await hre.ethers.getContractAt("IStargate", SB.Diamond.Address);
    StargateFacet.withdrawFromStargate(COIN.USDT, 1e9);
  });
})
