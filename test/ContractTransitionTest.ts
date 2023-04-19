import { ethers } from "hardhat";
import { expect } from "chai";
import { loadFixture } from "@nomicfoundation/hardhat-network-helpers";

import { CoinInterface } from "./libraries/DataStructures";
import SBFixture, { SBFixtureInterface } from "./libraries/SBFixture";
import CoinSetup from "./libraries/CoinSetup";
import { IStableBattle } from "../typechain-types";
import { BigNumber } from "ethers";
import migrateSB006 from "../scripts/migrateSB006";

describe('Contract Transition Test', async function () {

  let SB : SBFixtureInterface;
  let Coin : CoinInterface;
  const SB006Address = "0xC0662fAee7C84A03B1e58d60256cafeeb08Ab85d";
  const SB006 : IStableBattle = await ethers.getContractAt("IStableBattle", SB006Address);

  before(async () => {
    SB = await loadFixture(SBFixture);
    Coin = await loadFixture(CoinSetup);
  });

  it("Confirm initial assumptions", async () => {
    expect(await SB.Diamond.KnightFacet.getKnightsMintedTotal()).to.deep.equal(BigNumber.from(0));
    expect(await Coin.AUSDT.balanceOf(SB.Diamond.Address)).to.deep.equal(BigNumber.from(0));
    const knightsTotal = await SB006.getTotalKnightSupply();
    const ausdtBalance = await Coin.AUSDT.balanceOf(SB006.address);
    expect(knightsTotal.mul(BigNumber.from(1000).pow(await Coin.AUSDT.decimals())).gte(ausdtBalance)).to.be.true;
  //console.log("SB006 knight total", knightsTotal);
  //console.log("SB006 knight mints", await SB006.getKnightsMintedTotal());
  //console.log("SB006 AUSDT balance", ausdtBalance);
  });

  describe("Should stop SB006 and migrate knights from SB006 to SB", async () => {
    it("Should stop SB006 and migrate knights without errors", async () => {
      await migrateSB006(SB006Address);
    });

    it("Amount of knights minted is the same", async () => {
      const oldKnightsMintedTotal = await SB006.getKnightsMintedTotal();
      const newKnightsMintedTotal = await SB.Diamond.KnightFacet.getKnightsMintedTotal();
    //console.log("oldSB knight minted total", oldKnightsMintedTotal);
    //console.log("newSB knight minted total", newKnightsMintedTotal);
      expect(newKnightsMintedTotal).to.deep.equal(oldKnightsMintedTotal);
    });

    it("Amount of knights burned is the same", async () => {
      const oldKnightsBurnedTotal = await SB006.getKnightsBurnedTotal();
      const newKnightsBurnedTotal = await SB.Diamond.KnightFacet.getKnightsBurnedTotal();
    //console.log("oldSB knight minted total", oldKnightsBurnedTotal);
    //console.log("newSB knight minted total", newKnightsBurnedTotal);
      expect(newKnightsBurnedTotal).to.deep.equal(oldKnightsBurnedTotal);
    });

    it("Amount of AUSDT in SB is correct", async () => {
      const knightsTotal = await SB.Diamond.KnightFacet.getTotalKnightSupply();
      const ausdtBalance = await Coin.AUSDT.balanceOf(SB.Diamond.Address);
    //console.log("newSB knight total", knightsTotal);
    //console.log("newSB balance", ausdtBalance);
      const balanceFromKnightStakes = knightsTotal.mul(
        BigNumber.from(1000)
        .mul(BigNumber.from(10).pow(await Coin.AUSDT.decimals()))
      );
    //console.log("Balance from knight stakes", balanceFromKnightStakes)
      expect((balanceFromKnightStakes).lte(ausdtBalance)).to.be.true;
    });
  });
})
