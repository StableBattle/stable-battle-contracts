import { expect } from "chai";
import "@nomicfoundation/hardhat-chai-matchers";
import { loadFixture } from "@nomicfoundation/hardhat-network-helpers";

import { COIN, CoinInterface, POOL, gearSlot } from "./libraries/DataStructures";
import SBFixture, { SBFixtureInterface } from "./libraries/SBFixture";
import CoinSetup from "./libraries/CoinSetup";
import { BigNumber } from "ethers";
import coinsFixture from "./libraries/coinsFixture";

describe('GearFacetTest', async function () {
  let SB : SBFixtureInterface;
  let Coin : CoinInterface;

  let knight : BigNumber[] = [];

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
  })

  it('Should create 2 WEAPONs & 1 SHIELD correctly', async () => {
    await SB.Diamond.GearFacet.createGear(1000, gearSlot.WEAPON, "Rusty Sword");
    await SB.Diamond.GearFacet.createGear(2000, gearSlot.WEAPON, "Fine Sword");
    await SB.Diamond.GearFacet.createGear(3000, gearSlot.SHIELD, "Some Shield");
    expect(await SB.Diamond.GearFacet.getGearSlotOf(1000)).to.equal(1);
    expect(await SB.Diamond.GearFacet.getGearSlotOf(2000)).to.equal(1);
    expect(await SB.Diamond.GearFacet.getGearSlotOf(3000)).to.equal(2);
    expect(await SB.Diamond.GearFacet.getGearName(1000)).to.equal("Rusty Sword");
    expect(await SB.Diamond.GearFacet.getGearName(2000)).to.equal("Fine Sword");
    expect(await SB.Diamond.GearFacet.getGearName(3000)).to.equal("Some Shield");
  })

  it('Should mint 2 WEAPONs & 1 SHIELD correctly ', async () => {
    await SB.Diamond.GearFacet["mintGear(uint256,uint256)"](1000, 1);
    await SB.Diamond.GearFacet["mintGear(uint256,uint256)"](2000, 1);
    await SB.Diamond.GearFacet["mintGear(uint256,uint256)"](3000, 1);
    expect(await SB.Diamond.ItemsFacet.balanceOf(SB.owner.address, 1000)).to.equal(1);
    expect(await SB.Diamond.ItemsFacet.balanceOf(SB.owner.address, 2000)).to.equal(1);
    expect(await SB.Diamond.ItemsFacet.balanceOf(SB.owner.address, 3000)).to.equal(1);
    expect(await SB.Diamond.GearFacet["getGearEquipable(address,uint256)"](SB.owner.address, 1000)).to.equal(1);
    expect(await SB.Diamond.GearFacet["getGearEquipable(address,uint256)"](SB.owner.address, 2000)).to.equal(1);
    expect(await SB.Diamond.GearFacet["getGearEquipable(address,uint256)"](SB.owner.address, 3000)).to.equal(1);
  })

  it('Should equip Rusty Sword & Some Shield as 1 function call', async () => {
    await SB.Diamond.GearFacet.updateKnightGear(knight[0], [1000, 3000]);
    expect(await SB.Diamond.GearFacet.getEquipmentInSlot(knight[0], 1)).to.equal(1000);
    expect(await SB.Diamond.GearFacet.getEquipmentInSlot(knight[0], 2)).to.equal(3000);
    expect(await SB.Diamond.GearFacet["getGearEquipable(address,uint256)"](SB.owner.address, 1000)).to.equal(0);
    expect(await SB.Diamond.GearFacet["getGearEquipable(address,uint256)"](SB.owner.address, 2000)).to.equal(1);
    expect(await SB.Diamond.GearFacet["getGearEquipable(address,uint256)"](SB.owner.address, 3000)).to.equal(0);
  })

  it('Should unequip Rusty Sword & equip Fine Sword', async () => {
    await SB.Diamond.GearFacet.updateKnightGear(knight[0], [2000]);
    expect(await SB.Diamond.GearFacet.getEquipmentInSlot(knight[0], 1)).to.equal(2000);
    expect(await SB.Diamond.GearFacet["getGearEquipable(address,uint256)"](SB.owner.address, 1000)).to.equal(1);
    expect(await SB.Diamond.GearFacet["getGearEquipable(address,uint256)"](SB.owner.address, 2000)).to.equal(0);
    expect(await SB.Diamond.GearFacet["getGearEquipable(address,uint256)"](SB.owner.address, 3000)).to.equal(0);
  })

  it('Should correctly reequip Some Shield', async () => {
    await SB.Diamond.GearFacet.updateKnightGear(knight[0], [3000]);
    expect(await SB.Diamond.GearFacet.getEquipmentInSlot(knight[0], 1)).to.equal(2000);
    expect(await SB.Diamond.GearFacet.getEquipmentInSlot(knight[0], 2)).to.equal(3000);
    expect(await SB.Diamond.GearFacet["getGearEquipable(address,uint256)"](SB.owner.address, 1000)).to.equal(1);
    expect(await SB.Diamond.GearFacet["getGearEquipable(address,uint256)"](SB.owner.address, 2000)).to.equal(0);
    expect(await SB.Diamond.GearFacet["getGearEquipable(address,uint256)"](SB.owner.address, 3000)).to.equal(0);
  })

  it('Should correctly unequip Fine Sword', async () => {
    await SB.Diamond.GearFacet.updateKnightGear(knight[0], [1]);
    expect(await SB.Diamond.GearFacet.getEquipmentInSlot(knight[0], 1)).to.equal(0);
    expect(await SB.Diamond.GearFacet.getEquipmentInSlot(knight[0], 2)).to.equal(3000);
    expect(await SB.Diamond.GearFacet["getGearEquipable(address,uint256)"](SB.owner.address, 1000)).to.equal(1);
    expect(await SB.Diamond.GearFacet["getGearEquipable(address,uint256)"](SB.owner.address, 2000)).to.equal(1);
    expect(await SB.Diamond.GearFacet["getGearEquipable(address,uint256)"](SB.owner.address, 3000)).to.equal(0);
  })
})
