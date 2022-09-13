import hre from "hardhat";
import deployStableBattle from "../../scripts/deploy";
import { AAVE as AAVE_address } from "../../scripts/config/sb-init-addresses";
import { SBDFromAddress } from "./SBDFromAddress";
import useCoin from "./useCoin";


export const AAVE = async () => { await hre.ethers.getContractAt('IPool', AAVE_address[hre.network.name]); }
export const [SBDAddress, SBTAddress, SBVAddress] = async () => { await deployStableBattle(); }
export const SBD = async () => { await SBDFromAddress(SBDAddress); }
export const SBT = async () => { await hre.ethers.getContractAt("ISBT", SBTAddress); }
export const SBV = async () => { await hre.ethers.getContractAt("ISBV", SBVAddress); }
export const Coin = async () => { await useCoin(); }