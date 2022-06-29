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
    'TreasuryFacet'
  ]
  const cut = []
  //let ItemsSelectors = [
  //  '0x00fdd58e', '0x4e1273f4', '0x4f558e79', '0xe985e9c5', '0x3a711341',
  //  '0x2eb2c2d6', '0xf242432a', '0xa22cb465', '0xbd85b039', '0x0e89341c']
  for (const FacetName of FacetNames) {
    const Facet = await ethers.getContractFactory(FacetName)
    const facet = await Facet.deploy({gasLimit: 30000000})
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
  let USDT_address  = ethers.utils.getAddress("0x21C561e551638401b937b03fE5a0a0652B99B7DD")
  let AAVE_address  = ethers.utils.getAddress("0x6C9fB0D5bD9429eb9Cd96B85B81d872281771E6B")
  let SBT_address   = SBT_address_
  let SBV_address   = SBV_address_
  let knight_offset = 1000000000
  let uri = "ex_uri"
  let max_members = 10
  let levelThresholds = [0, 100, 200, 300, 400, 500, 600, 700, 800, 900]
  let reward_per_block = 100
  let args = [[
    USDT_address,
    AAVE_address,
    SBT_address,
    SBV_address,
    knight_offset,
    uri,
    max_members,
    levelThresholds,
    reward_per_block
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
}

exports.initSBD = initSBD