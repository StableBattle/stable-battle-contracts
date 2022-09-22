import hre from "hardhat";
import { IERC20Mintable } from "../../typechain-types";
import {
  USDT as USDTAddress,
  USDC as USDCAddress,
  EURS as EURSAddress
} from "../../scripts/config/sb-init-addresses";

export interface CoinInterface {
  readonly [index: string]: IERC20Mintable
}

export default async function CoinSetup() : Promise<CoinInterface> {
  return {
    USDT: await hre.ethers.getContractAt("IERC20Mintable", USDTAddress[hre.network.name]),
    USDC: await hre.ethers.getContractAt("IERC20Mintable", USDCAddress[hre.network.name]),
    EURS: await hre.ethers.getContractAt("IERC20Mintable", EURSAddress[hre.network.name])
  }
}