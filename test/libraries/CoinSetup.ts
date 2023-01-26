import hre from "hardhat";
import { IERC20Mintable } from "../../typechain-types";
import {
  USDT as USDTAddress,
  USDC as USDCAddress,
  EURS as EURSAddress,
  AUSDT as AUSDTAddress,
  AUSDC as AUSDCAddress,
  AEURS as AEURSAddress
} from "../../scripts/config/sb-init-addresses";

export interface CoinInterface {
  readonly [index: string]: IERC20Mintable
}

export default async function CoinSetup() : Promise<CoinInterface> {
  return {
    USDT: await hre.ethers.getContractAt("IERC20Mintable", USDTAddress[hre.network.name]),
    USDC: await hre.ethers.getContractAt("IERC20Mintable", USDCAddress[hre.network.name]),
    EURS: await hre.ethers.getContractAt("IERC20Mintable", EURSAddress[hre.network.name]),
    AUSDT: await hre.ethers.getContractAt("IERC20Mintable", AUSDTAddress[hre.network.name]),
    AUSDC: await hre.ethers.getContractAt("IERC20Mintable", AUSDCAddress[hre.network.name]),
    AEURS: await hre.ethers.getContractAt("IERC20Mintable", AEURSAddress[hre.network.name])
  }
}