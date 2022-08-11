import * as fs from "fs";
import * as readline from "readline";
import { ethers } from "hardhat";

const owner_address = 
  ethers.utils.getAddress(
    process.env.PUBLIC_KEY || ""
  );
const DiamondCutFacet_address = 
  ethers.utils.getAddress(
    fs.readFileSync("./scripts/dep_args/DiamondCutFacet_address.txt", "utf8")
  );
//console.log("diamond_args: ", [owner_address, DiamondCutFacet_address])

module.exports = [owner_address, DiamondCutFacet_address];