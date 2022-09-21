/* global describe it before ethers */

const { deployStableBattle } = require('../scripts/deploy.js')

const { assert, expect } = require('chai')
const { BigNumber } = require('ethers')

describe('KnightFacetTest', async function () {
  let AAVE_address = ethers.utils.getAddress("0x368EedF3f56ad10b9bC57eed4Dac65B26Bb667f6")
  let USDT_address = ethers.utils.getAddress("0xC2C527C0CACF457746Bd31B2a698Fe89de2b6d49")
  let USDC_address = ethers.utils.getAddress("0xA2025B15a1757311bfD68cb14eaeFCc237AF5b43")
  let knightPrice = { USDT: 1e9, USDC: 1e9, TEST: 0}
  let COIN = []
  let knights = []
  let numberOfCoins = 2;
  let numberOfPools = 1;
  let owner
  let user1
  let user2
  let users
  let USDT
  let USDC
  let AAVE
  let SBD
  let SBT
  let SBV
  let tx
  let receipt
  let result
  let eventCount = 0
  //const addresses = []

  before(async function () {
    users = await ethers.getSigners()
    USDT = await ethers.getContractAt('IERC20Mintable', USDT_address)
    USDC = await ethers.getContractAt('IERC20Mintable', USDC_address)
    COIN[1] = USDT; COIN[2] = USDC;
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
    for (let i = 0; i < 10; i++) {
      const amount = (BigNumber.from(10000)).mul((BigNumber.from(10)).pow(await USDT.decimals()));
      await USDT.connect(users[i]).mint(amount);
      await USDT.connect(users[i]).approve(SBD.Address, amount);
    }
  })

  it('should mint 10 knights per user', async () => {
    for (let i = 0; i < 10; i++) {
      const KF = await SBD.KnightFacet.connect(users[i]);
      for (let j = 0; j < 10; j++) {
        await KF.mintKnight(1, 1);
        let eventsKnightMinted = await SBD.KnightFacet.queryFilter('KnightMinted')
        knights[eventCount] = eventsKnightMinted[eventCount].args.knightId;
        eventCount++;
      }
    }
  })

  it('should burn 10 knights per user', async () => {
    for (let i = 0; i < 10; i++) {
      const KF = await SBD.KnightFacet.connect(users[i]);
      for (let j = 0; j < 10; j++) {
        await KF.burnKnight(knights[j + i * 10]);
      }
    }
  })
})
