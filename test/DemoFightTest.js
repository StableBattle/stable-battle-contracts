/* global describe it before ethers */

const { deployStableBattle } = require('../scripts/deploy.js')

const { expect } = require('chai')
const { ethers } = require('hardhat')

describe('DemoFightFacetTest', async function () {
  let AAVE_address = ethers.utils.getAddress("0x368EedF3f56ad10b9bC57eed4Dac65B26Bb667f6")
  let USDT_address = ethers.utils.getAddress("0xC2C527C0CACF457746Bd31B2a698Fe89de2b6d49")
  let USDC_address = ethers.utils.getAddress("0xA2025B15a1757311bfD68cb14eaeFCc237AF5b43")
  let knightPrice = { USDC: 1e9, USDT: 1e9 }
  let Pool = {
    NONE : 0,
    TEST : 1,
    AAVE : 2
  }
  let Coin = {
    NONE : 0,
    TEST : 1,
    USDT : 2,
    USDC : 3
  }
  let user = []
  let USDC = []
  let USDT = []
  let AAVE
  let SBD
  let SBT
  let SBV

  let knightId = []
  let KnightFacet = []
  let preTimeskipReward
  let afterTimeskipReward
  //const addresses = []

  before(async function () {
    [user[0], user[1], user[2]] = await ethers.getSigners()
    USDC[0] = await ethers.getContractAt('IERC20Mintable', USDC_address)
    USDC[1] = USDC[0].connect(user[1])
    USDC[2] = USDC[0].connect(user[2])
    USDT[0] = await ethers.getContractAt('IERC20Mintable', USDT_address)
    USDT[1] = USDT[0].connect(user[1])
    USDT[2] = USDT[0].connect(user[2])
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
      DemoFightFacet: await ethers.getContractAt('DemoFightFacet', SBDAddress),
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
    
    
    KnightFacet[0] = SBD.KnightFacet
    KnightFacet[1] = SBD.KnightFacet.connect(user[1])
    KnightFacet[2] = SBD.KnightFacet.connect(user[2])
    for (let i = 0; i < 3; i++) {
      //mint test knight
    //await KnightFacet[i].mintKnight(2, 3)

      await USDT[i].mint(knightPrice.USDT)
      await USDT[i].approve(SBD.Address, knightPrice.USDT)
    //console.log(await USDT[i].allowance(user[i].address, SBD.Address))
      await KnightFacet[i].mintKnight(2, 2)
      
    //await USDC[i].mint(knightPrice.USDC)
    //await USDC[i].approve(SBD.Address, knightPrice.USDC)
    //console.log(await USDC[i].allowance(user[i].address, SBD.Address))
    //await KnightFacet[i].mintKnight(2, 3)
    }

    let eventsKnightMinted = await SBD.KnightFacet.queryFilter('KnightMinted')
    knightId[0] = eventsKnightMinted[0].args.knightId
    knightId[1] = eventsKnightMinted[1].args.knightId
    knightId[2] = eventsKnightMinted[2].args.knightId
  //console.log("---------------------");
  })

  it('Should show correct stake values', async () => {
    let totalYield = await SBD.DemoFightFacet.getTotalYield();
    let stakedByKnights = await SBD.DemoFightFacet.getStakedByKnights();
    preTimeskipReward = await SBD.DemoFightFacet.getCurrentYield();
  //console.log("totalYield: ", totalYield);
  //console.log("stakedByKnights: ", stakedByKnights);
  //console.log("currentReward: ", preTimeskipReward);
    expect(stakedByKnights).to.be.equal(3e9);
    expect(totalYield).to.be.at.least(stakedByKnights);
  //console.log("---------------------");
  })

  it('Should incerase stake as time passes', async () => {
    //0x64 = 10 blocks, 0x3c = 60 seconds
  //console.log("Timeskip 10 blocks, 60 seconds each")
    await hre.network.provider.send("hardhat_mine", ["0x3e8", "0x3c"]);
    afterTimeskipReward = await SBD.DemoFightFacet.getCurrentYield();
  //console.log("currentYield", afterTimeskipReward);
    expect(afterTimeskipReward).to.be.above(preTimeskipReward);
  //console.log("---------------------");
  })

  it('Should properly update battle results', async () => {
    let currentYield = await SBD.DemoFightFacet.getCurrentYield();
    await SBD.DemoFightFacet.battleWonBy(user[0].address, currentYield);
    let lockedYield = await SBD.DemoFightFacet.getLockedYield();
    let userReward = await SBD.DemoFightFacet.getUserReward(user[0].address);
    currentYield = await SBD.DemoFightFacet.getCurrentYield();
  //console.log("lockedYield: ", lockedYield);
  //console.log("userReward: ", userReward);
  //console.log("currentYield: ", currentYield);
    expect(lockedYield).to.be.at.least(afterTimeskipReward);
    expect(userReward).to.be.equal(lockedYield);
    expect(currentYield).to.at.least(0);
  //console.log("---------------------");
  })

  it('Should be able to claim reward correctly', async () => {
    let userReward = await SBD.DemoFightFacet.getUserReward(user[0].address);
    let balanceBefore = await USDT[0].balanceOf(user[0].address);
    await SBD.DemoFightFacet.claimReward(user[0].address);
    let balanceAfter = await USDT[0].balanceOf(user[0].address);
    expect(balanceAfter - balanceBefore).to.be.equal(userReward)
    let lockedYield = await SBD.DemoFightFacet.getLockedYield();
    userReward = await SBD.DemoFightFacet.getUserReward(user[0].address);
  //console.log("lockedYield: ", lockedYield);
  //console.log("userReward: ", userReward);
    expect(lockedYield).to.be.equal(0);
    expect(userReward).to.be.equal(0);
  //console.log("---------------------");
  })

  it('Stake should not dip below 3000 USDC after reward claim', async () => {
    let totalYield = await SBD.DemoFightFacet.getTotalYield();
    let stakedByKnights = await SBD.DemoFightFacet.getStakedByKnights();
  //console.log("totalYield: ", totalYield);
  //console.log("stakedByKnights", stakedByKnights);
    expect(totalYield).to.be.at.least(stakedByKnights);
  //console.log("---------------------");
  })

})
