/* global ethers fs */
/* eslint prefer-const: "off" */
const fs = require('fs')
const { ethers } = require('hardhat')

async function deployDummy () {
  const Dummy = await ethers.getContractFactory('StableBattleDummy')
  const dummy = await Dummy.deploy()
  await dummy.deployed()
  console.log('Dummy deployed: ', dummy.address)

  if (fs.existsSync("./scripts/dep_args/dummy_address.txt")) {
    fs.unlinkSync("./scripts/dep_args/dummy_address.txt")
  }

  fs.writeFileSync(
    "./scripts/dep_args/dummy_address.txt",
    dummy.address,
    {flag: "a"})
  
  return dummy.address
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
if (require.main === module) {
  deployDummy()
    .then(() => process.exit(0))
    .catch(error => {
      console.error(error)
      process.exit(1)
    })
}

exports.deployDummy = deployDummy
