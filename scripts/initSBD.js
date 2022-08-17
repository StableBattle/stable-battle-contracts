/* global ethers */
/* eslint prefer-const: "off" */
const fs = require('fs')

const { getSelectors, FacetCutAction } = require('./libraries/diamond.js')

async function initSBD (SBD_address, SBT_address_, SBV_address_) {

  // deploy SBInit
  // SBInit provides a function that is called when the diamond is upgraded to initialize state variables
  // Read about how the diamondCut function works here: https://eips.ethereum.org/EIPS/eip-2535#addingreplacingremoving-functions
  const SBInit = await ethers.getContractFactory('SBInit')
  const diamondInit = await SBInit.deploy({gasLimit: 3000000})
  await diamondInit.deployed()
  console.log('SBInit deployed:', diamondInit.address)

  // deploy SB facets
  console.log('')
  console.log('Deploying facets')
  const FacetNames = [
    'DiamondLoupeFacet',
    'OwnershipFacet',
    //Deploy ItemsFacet first since it's inherited to mint knights and items
    'ItemsFacet',
    'ClanFacet',
    'ForgeFacet',
    'KnightFacet',
    'SBVHookFacet',
    'TournamentFacet',
    'TreasuryFacet',
    'GearFacet',
    'EtherscanFacet',
    'DemoFightFacet'
  ]
  const cut = []
  //let ItemsSelectors = [
  //  '0x00fdd58e', '0x4e1273f4', '0x4f558e79', '0xe985e9c5', '0x3a711341',
  //  '0x2eb2c2d6', '0xf242432a', '0xa22cb465', '0xbd85b039', '0x0e89341c']
  for (const FacetName of FacetNames) {
    const Facet = await ethers.getContractFactory(FacetName)
    const facet = await Facet.deploy({gasLimit: 5000000})
    await facet.deployed()
    console.log(`${FacetName} deployed: ${facet.address}`)
    if (FacetName == "ItemsFacet") {
      ItemsSelectors = getSelectors(facet)
      //console.log("ItemsSelectors: ", ItemsSelectors)
      cut.push({
        facetAddress: facet.address,
        action: FacetCutAction.Add,
        functionSelectors: ItemsSelectors
      })
    } else if (FacetName == "ForgeFacet" || FacetName == "KnightFacet") {
      cut.push({
        facetAddress: facet.address,
        action: FacetCutAction.Add,
        functionSelectors: getSelectors(facet).remove(ItemsSelectors)
      })
    } else {
      cut.push({
        facetAddress: facet.address,
        action: FacetCutAction.Add,
        functionSelectors: getSelectors(facet)
      })
    }
    fs.writeFileSync("./scripts/dep_args/facet_addresses.txt", facet.address + "\n", {flag: "a"})
  }

  // upgrade SBD with facets
  console.log('')
  //console.log('Diamond Cut:', cut)
  const diamondCut = await ethers.getContractAt('IDiamondCut', SBD_address)
  let tx
  let receipt
  let AAVE_address = ethers.constants.AddressZero
  let USDT_address = ethers.constants.AddressZero
  let USDC_address = ethers.constants.AddressZero
  let AAVE_USDT_address = ethers.constants.AddressZero
  let AAVE_USDC_address = ethers.constants.AddressZero
  if (hre.network.name === 'polygonMumbai') {
    AAVE_address = ethers.utils.getAddress("0x6C9fB0D5bD9429eb9Cd96B85B81d872281771E6B")

    USDT_address = ethers.utils.getAddress("0x21C561e551638401b937b03fE5a0a0652B99B7DD")
    USDC_address = ethers.utils.getAddress("0x9aa7fEc87CA69695Dd1f879567CcF49F3ba417E2")
    EURS_address = ethers.utils.getAddress("0x302567472401C7c7B50ee7eb3418c375D8E3F728")
    
    AAVE_USDT_address = ethers.utils.getAddress("0x6Ca4abE253bd510fCA862b5aBc51211C1E1E8925")
    AAVE_USDC_address = ethers.utils.getAddress("0xCdc2854e97798AfDC74BC420BD5060e022D14607")
    AAVE_EURS_address = ethers.utils.getAddress("0xf6AeDD279Aae7361e70030515f56c22A16d81433")
  } else if (hre.network.name === 'hardhat' || hre.network.name === 'goerli') {
    AAVE_address = ethers.utils.getAddress("0x368EedF3f56ad10b9bC57eed4Dac65B26Bb667f6")

    USDT_address = ethers.utils.getAddress("0xC2C527C0CACF457746Bd31B2a698Fe89de2b6d49")
    USDC_address = ethers.utils.getAddress("0xA2025B15a1757311bfD68cb14eaeFCc237AF5b43")
    EURS_address = ethers.utils.getAddress("0xaA63E0C86b531E2eDFE9F91F6436dF20C301963D")
    
    AAVE_USDT_address = ethers.utils.getAddress("0x73258E6fb96ecAc8a979826d503B45803a382d68")
    AAVE_USDC_address = ethers.utils.getAddress("0x1Ee669290939f8a8864497Af3BC83728715265FF")
    AAVE_EURS_address = ethers.utils.getAddress("0xc31E63CB07209DFD2c7Edb3FB385331be2a17209")
  }
  let SBT_address  = SBT_address_
  let SBV_address  = SBV_address_
  let args = [[
    AAVE_address,
    USDT_address,
    USDC_address,
    EURS_address,
    AAVE_USDT_address,
    AAVE_USDC_address,
    AAVE_EURS_address,
    SBT_address,
    SBV_address,
  ]]
  // call to init function
  let functionCall = diamondInit.interface.encodeFunctionData('SB_init', args)
  tx = await diamondCut.diamondCut(cut, diamondInit.address, functionCall)
  console.log('SBD cut tx: ', tx.hash)
  receipt = await tx.wait()
  if (!receipt.status) {
    throw Error(`SBD upgrade failed: ${tx.hash}`)
  }
  console.log('Completed SB diamond cut')
  return await hre.ethers.provider.getBlock("latest")
}

exports.initSBD = initSBD