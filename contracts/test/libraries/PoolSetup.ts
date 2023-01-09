import hre from "hardhat";
import { IPool } from "../../../typechain-types";
import { AAVE as AAVEAddress } from "../../../scripts/config/sb-init-addresses";

export interface CoinInterface {
  readonly [index: string]: IPool
}

export default async function PoolSetup() : Promise<CoinInterface> {
  return {
    AAVE: await hre.ethers.getContractAt("IPool", AAVEAddress[hre.network.name]),
  }
}