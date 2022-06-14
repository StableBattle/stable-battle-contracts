/* global ethers fs */
/* eslint prefer-const: "off" */
const fs = require('fs')

const { getSelectors, FacetCutAction } = require('./libraries/diamond.js')

async function initSBT (SBT_address, Clan_address, Treasury_address) {
  const accounts = await ethers.getSigners()
  const contractOwner = accounts[0]

  // deploy SBInit
  // SBInit provides a function that is called when the diamond is upgraded to initialize state variables
  // Read about how the diamondCut function works here: https://eips.ethereum.org/EIPS/eip-2535#addingreplacingremoving-functions
  const SBTInit = await ethers.getContractFactory('SBTInit')
  const diamondInit = await SBTInit.deploy({gasLimit: 3000000})
  await diamondInit.deployed()
  console.log('SBInit deployed:', diamondInit.address)

  // deploy SB facets
  console.log('')
  console.log('Deploying facets')
  const FacetNames = [
    'DiamondLoupeFacet',
    'OwnershipFacet',
    'SBTFacet'
  ]
  const cut = []
  for (const FacetName of FacetNames) {
    const Facet = await ethers.getContractFactory(FacetName)
    const facet = await Facet.deploy({gasLimit: 3000000})
    await facet.deployed()
    console.log(`${FacetName} deployed: ${facet.address}`)
    cut.push({
      facetAddress: facet.address,
      action: FacetCutAction.Add,
      functionSelectors: getSelectors(facet)
    })
    fs.writeFileSync("./scripts/dep_args/facet_addresses.txt", facet.address + "\n", {flag: "a"})
  }

  // upgrade SBT with facets
  console.log('')
  console.log('Diamond Cut:', cut)
  const diamondCut = await ethers.getContractAt('IDiamondCut', SBT_address)
  let tx
  let receipt

  let ClanFacetAddress = Clan_address
  let minters = [Treasury_address]
  let burners = []
    //premint data
  let premint_beneficiaries = [contractOwner.address];
  let beneficiaries_balances = [10000];
  let totalSupplyPremint = 10000;

  let args = [[
    ClanFacetAddress,
    minters,
    burners,
    premint_beneficiaries,
    beneficiaries_balances,
    totalSupplyPremint
  ]]
  // call to init function
  let functionCall = diamondInit.interface.encodeFunctionData('SBT_init', args)
  tx = await diamondCut.diamondCut(cut, diamondInit.address, functionCall)
  console.log('SBT cut tx: ', tx.hash)
  receipt = await tx.wait()
  if (!receipt.status) {
    throw Error(`SBT upgrade failed: ${tx.hash}`)
  }
  console.log('Completed SBT diamond cut')
}

exports.initSBT = initSBT