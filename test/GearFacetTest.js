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

describe('GearFacetTest', async function () {
  let USDT_address = ethers.utils.getAddress("0x21C561e551638401b937b03fE5a0a0652B99B7DD")
  let AAVE_address = ethers.utils.getAddress("0x6C9fB0D5bD9429eb9Cd96B85B81d872281771E6B")
  let knightPrice = { AAVE: 1e9, OTHER: 0}
  let gearType = {
    EMPTY : 0,
    WEAPON : 1,
    SHIELD : 2
  }
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
      ForgeFacet: await ethers.getContractAt('ForgeFacet', SBDAddress),
      ItemsFacet: await ethers.getContractAt('ItemsFacet', SBDAddress),
      KnightFacet: await ethers.getContractAt('KnightFacet', SBDAddress),
      TournamentFacet: await ethers.getContractAt('TournamentFacet', SBDAddress),
      TreasuryFacet: await ethers.getContractAt('TreasuryFacet', SBDAddress),
      SBVHookFacet: await ethers.getContractAt('SBVHookFacet', SBDAddress),
      GearFacet: await ethers.getContractAt('GearFacet', SBDAddress),
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
    await SBD.KnightFacet.mintKnight(1)

    let eventsKnightMinted = await SBD.KnightFacet.queryFilter('KnightMinted')
    knightId = eventsKnightMinted[0].args.knightId
  })

  it('Should create 2 WEAPONs & 1 SHIELD correctly', async () => {
    await SBD.GearFacet.createGear(1000, gearType.WEAPON, "Rusty Sword");
    await SBD.GearFacet.createGear(2000, gearType.WEAPON, "Fine Sword");
    await SBD.GearFacet.createGear(3000, gearType.SHIELD, "Some Shield");
    expect(await SBD.GearFacet.getGearSlot(1000)).to.equal(1);
    expect(await SBD.GearFacet.getGearSlot(2000)).to.equal(1);
    expect(await SBD.GearFacet.getGearSlot(3000)).to.equal(2);
    expect(await SBD.GearFacet.getGearName(1000)).to.equal("Rusty Sword");
    expect(await SBD.GearFacet.getGearName(2000)).to.equal("Fine Sword");
    expect(await SBD.GearFacet.getGearName(3000)).to.equal("Some Shield");
  })

  it('Should mint 2 WEAPONs & 1 SHIELD correctly ', async () => {
    await SBD.ForgeFacet["mintGear(uint256,uint256)"](1000, 1);
    await SBD.ForgeFacet["mintGear(uint256,uint256)"](2000, 1);
    await SBD.ForgeFacet["mintGear(uint256,uint256)"](3000, 1);
    expect(await SBD.ItemsFacet.balanceOf(owner.address, 1000)).to.equal(1);
    expect(await SBD.ItemsFacet.balanceOf(owner.address, 2000)).to.equal(1);
    expect(await SBD.ItemsFacet.balanceOf(owner.address, 3000)).to.equal(1);
    expect(await SBD.GearFacet.getGearEquipable(owner.address, 1000)).to.equal(1);
    expect(await SBD.GearFacet.getGearEquipable(owner.address, 2000)).to.equal(1);
    expect(await SBD.GearFacet.getGearEquipable(owner.address, 3000)).to.equal(1);
  })

  it('Should equip Rusty Sword & Some Shield as 1 function call', async () => {
    await SBD.GearFacet.updateKnightGear(knightId, [1000, 3000]);
    expect(await SBD.GearFacet.getEquipmentInSlot(knightId, 1)).to.equal(1000);
    expect(await SBD.GearFacet.getEquipmentInSlot(knightId, 2)).to.equal(3000);
    expect(await SBD.GearFacet.getGearEquipable(owner.address, 1000)).to.equal(0);
    expect(await SBD.GearFacet.getGearEquipable(owner.address, 2000)).to.equal(1);
    expect(await SBD.GearFacet.getGearEquipable(owner.address, 3000)).to.equal(0);
  })

  it('Should unequip Rusty Sword & equip Fine Sword', async () => {
    await SBD.GearFacet.updateKnightGear(knightId, [2000]);
    expect(await SBD.GearFacet.getEquipmentInSlot(knightId, 1)).to.equal(2000);
    expect(await SBD.GearFacet.getGearEquipable(owner.address, 1000)).to.equal(1);
    expect(await SBD.GearFacet.getGearEquipable(owner.address, 2000)).to.equal(0);
    expect(await SBD.GearFacet.getGearEquipable(owner.address, 3000)).to.equal(0);
  })

  it('Should correctly reequip Some Shield', async () => {
    await SBD.GearFacet.updateKnightGear(knightId, [3000]);
    expect(await SBD.GearFacet.getEquipmentInSlot(knightId, 1)).to.equal(2000);
    expect(await SBD.GearFacet.getEquipmentInSlot(knightId, 2)).to.equal(3000);
    expect(await SBD.GearFacet.getGearEquipable(owner.address, 1000)).to.equal(1);
    expect(await SBD.GearFacet.getGearEquipable(owner.address, 2000)).to.equal(0);
    expect(await SBD.GearFacet.getGearEquipable(owner.address, 3000)).to.equal(0);
  })

  it('Should correctly unequip Fine Sword', async () => {
    await SBD.GearFacet.updateKnightGear(knightId, [1]);
    expect(await SBD.GearFacet.getEquipmentInSlot(knightId, 1)).to.equal(0);
    expect(await SBD.GearFacet.getEquipmentInSlot(knightId, 2)).to.equal(3000);
    expect(await SBD.GearFacet.getGearEquipable(owner.address, 1000)).to.equal(1);
    expect(await SBD.GearFacet.getGearEquipable(owner.address, 2000)).to.equal(1);
    expect(await SBD.GearFacet.getGearEquipable(owner.address, 3000)).to.equal(0);
  })
})
