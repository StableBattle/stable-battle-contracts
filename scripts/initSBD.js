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
  if (hre.network.name === 'hardhat' || hre.network.name === 'polygonMumbai') {
    AAVE_address = ethers.utils.getAddress("0x6C9fB0D5bD9429eb9Cd96B85B81d872281771E6B")
    USDT_address = ethers.utils.getAddress("0x21C561e551638401b937b03fE5a0a0652B99B7DD")
    USDC_address = ethers.utils.getAddress("0x9aa7fEc87CA69695Dd1f879567CcF49F3ba417E2")
    AAVE_USDT_address = ethers.utils.getAddress("0x6Ca4abE253bd510fCA862b5aBc51211C1E1E8925")
    AAVE_USDC_address = ethers.utils.getAddress("0xCdc2854e97798AfDC74BC420BD5060e022D14607")
  } else if (hre.network.name === 'rinkeby') {
    AAVE_address = ethers.utils.getAddress("0xE039BdF1d874d27338e09B55CB09879Dedca52D8")
    USDT_address = ethers.utils.getAddress("0x326005cFdF58bfB38650396836BEBF815F5ab4dD")
    USDC_address = ethers.utils.getAddress("0xb18d016cDD2d9439A19f15633005A6b2cd6Aa774")
  } else if (hre.network.name === 'ropsten') {
    AAVE_address = ethers.utils.getAddress("0x23a85024f54A19e243bA7a74E339a5C80998c7a4")
    USDT_address = ethers.utils.getAddress("0xAf5a1D0523cF9E38005E234a9eea82cc167CC474")
    USDC_address = ethers.utils.getAddress("0xe99F86Ec081BcA8b1627BDf8062C19fAcC79997B")
  } else if (hre.network.name === 'arbitrumTestnet') {
    USDT_address = ethers.utils.getAddress("0x7c53810c756C636cEF076c92D5D7C04555694E76")
    USDC_address = ethers.utils.getAddress("0x774382EF196781400a335AF0c4219eEd684ED713")
    AAVE_address = ethers.utils.getAddress("")
  } else if (hre.network.name === 'avalancheFujiTestnet') {
  } else if (hre.network.name === 'ftmTestnet') {
  } else if (hre.network.name === 'harmonyTest') {
  } else if (hre.network.name === 'optimisticKovan') {
  }
  let SBT_address  = SBT_address_
  let SBV_address  = SBV_address_
  let args = [[
    AAVE_address,
    USDT_address,
    USDC_address,
    AAVE_USDT_address,
    AAVE_USDC_address,
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