import hre from "hardhat";
import SBDFromAddress, { SBDInterface } from "./SBDFromAddress";
import { ISBT, ISBV } from "../../../typechain-types";
import { BigNumber } from "ethers";
import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";
import deploy from "../../../scripts/deploy";


export interface knightPriceInterface {
  readonly [index: string]: BigNumber
}

export const knightPrice = {
  USDT : BigNumber.from(1e9),
  USDC : BigNumber.from(1e9),
  EURS : BigNumber.from(1e9),
  TEST : BigNumber.from(0)
}

export interface SBFixtureInterface {
  Diamond : SBDInterface,
  SBT : ISBT,
  SBV : ISBV,
  knightPrice : knightPriceInterface,
  users : SignerWithAddress[],
  owner : SignerWithAddress,
  predeployBlock : number
}

export default async function SBFixture() : Promise<SBFixtureInterface> {
  const users = await hre.ethers.getSigners();
  const owner = users[0];
  const [SBDAddress, SBTAddress, SBVAddress, predeployBlock] = await deploy();
  return {
    Diamond : await SBDFromAddress(SBDAddress),
    SBT : await hre.ethers.getContractAt("ISBT", SBTAddress),
    SBV : await hre.ethers.getContractAt("ISBV", SBVAddress),
    knightPrice : knightPrice,
    users : users,
    owner : owner,
    predeployBlock : predeployBlock
  }
}