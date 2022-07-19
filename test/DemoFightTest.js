/* global describe it before ethers */

const { deployStableBattle } = require('../scripts/deploy.js')

const { expect } = require('chai')
const { ethers } = require('hardhat')

describe('DemoFightFacetTest', async function () {
  let USDC_address = ethers.utils.getAddress("0x9aa7fEc87CA69695Dd1f879567CcF49F3ba417E2")
  let USDT_address = ethers.utils.getAddress("0x21C561e551638401b937b03fE5a0a0652B99B7DD")
  let AAVE_address = ethers.utils.getAddress("0x6C9fB0D5bD9429eb9Cd96B85B81d872281771E6B")
  let knightPrice = { USDC: 1e9, USDT: 1e9 }
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
      await KnightFacet[i].mintKnight(1, 1)
      
      await USDC[i].mint(knightPrice.USDC)
      await USDC[i].approve(SBD.Address, knightPrice.USDC)
    //console.log(await USDC[i].allowance(user[i].address, SBD.Address))
      await KnightFacet[i].mintKnight(1, 2)
    }
    for (let i = 0; i < 3; i++) {
    }

    let eventsKnightMinted = await SBD.KnightFacet.queryFilter('KnightMinted')
    knightId[0] = eventsKnightMinted[0].args.knightId
    knightId[1] = eventsKnightMinted[1].args.knightId
    knightId[2] = eventsKnightMinted[2].args.knightId
  })

  it('Should show correct stake values', async () => {
    let totalYield = await SBD.DemoFightFacet.getTotalYield();
    let stakedByKnights = await SBD.DemoFightFacet.getStakedByKnights();
    preTimeskipReward = await SBD.DemoFightFacet.getCurrentYield();
  //console.log("stakeTotal", stakeTotal);
  //console.log("stakeByKnights", stakeByKnights);
  //console.log("currentReward", preTimeskipReward);
    expect(stakedByKnights).to.be.equal(6e9);
    expect(totalYield).to.be.at.least(stakedByKnights);
  })

  it('Should incerase stake as time passes', async () => {
    //0x64 = 10 blocks, 0x3c = 60 seconds
  //console.log("Timeskip 10 blocks, 60 seconds each")
    await hre.network.provider.send("hardhat_mine", ["0x3e8", "0x3c"]);
    afterTimeskipReward = await SBD.DemoFightFacet.getCurrentYield();
  //console.log("currentYield", afterTimeskipReward);
    expect(afterTimeskipReward).to.be.above(preTimeskipReward);
  })

  it('Should properly update battle results', async () => {
    let currentYield = await SBD.DemoFightFacet.getCurrentYield();
    await SBD.DemoFightFacet.battleWonBy(user[0].address, currentYield);
    let lockedYield = await SBD.DemoFightFacet.getLockedYield();
    let userReward = await SBD.DemoFightFacet.getUserReward(user[0].address);
    currentYield = await SBD.DemoFightFacet.getCurrentYield();
  //console.log("lockedYield", lockedYield);
  //console.log("userReward", userReward);
  //console.log("currentYield", currentYield);
    expect(lockedYield).to.be.at.least(afterTimeskipReward);
    expect(userReward).to.be.equal(lockedYield);
    expect(currentYield).to.be.equal(0);
  })

  it('Should be able to claim reward correctly', async () => {
    let userReward = await SBD.DemoFightFacet.getUserReward(user[0].address);
    let balanceBefore = await USDC[0].balanceOf(user[0].address);
    await SBD.DemoFightFacet.claimReward(user[0].address);
    let balanceAfter = await USDC[0].balanceOf(user[0].address);
    expect(balanceAfter - balanceBefore).to.be.equal(userReward)
    let lockedYield = await SBD.DemoFightFacet.getLockedYield();
    userReward = await SBD.DemoFightFacet.getUserReward(user[0].address);
  //console.log("lockedUntilClaimed", lockedUntilClaimed);
  //console.log("userReward", userReward);
    expect(lockedYield).to.be.equal(0);
    expect(userReward).to.be.equal(0);
  })

  it('Stake should not dip below 3000 USDC after reward claim', async () => {
    let totalYield = await SBD.DemoFightFacet.getTotalYield();
    let stakedByKnights = await SBD.DemoFightFacet.getStakedByKnights();
  //console.log("totalYield", totalYield);
  //console.log("stakedByKnights", stakedByKnights);
    expect(totalYield).to.be.at.least(stakedByKnights);
  })
})
