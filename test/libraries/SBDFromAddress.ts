import hre from "hardhat";
import { 
  ClanFacet,
  DiamondCutFacet,
  DiamondLoupeFacet,
  EtherscanFacet,
  GearFacet,
  ItemsFacet,
  KnightFacet,
  OwnershipFacet,
  SBVHookFacet,
  TournamentFacet,
  TreasuryFacet
} from "../../typechain-types";

export interface SBDInterface {
  ClanFacet: ClanFacet;
  CutFacet: DiamondCutFacet;
  LoupeFacet: DiamondLoupeFacet;
  EtherscanFacet: EtherscanFacet;
  GearFacet: GearFacet;
  ItemsFacet: ItemsFacet;
  KnightFacet: KnightFacet;
  OwnershipFacet: OwnershipFacet;
  SBVHookFacet: SBVHookFacet;
  TournamentFacet: TournamentFacet;
  TreasuryFacet: TreasuryFacet;
  Address: string
}

export default async function SBDFromAddress(SBDAddress: string) : Promise<SBDInterface> {
  return {
    CutFacet: await hre.ethers.getContractAt('DiamondCutFacet', SBDAddress),
    LoupeFacet: await hre.ethers.getContractAt('DiamondLoupeFacet', SBDAddress),
    EtherscanFacet: await hre.ethers.getContractAt('EtherscanFacet', SBDAddress),
    GearFacet: await hre.ethers.getContractAt('GearFacet', SBDAddress),
    OwnershipFacet: await hre.ethers.getContractAt('OwnershipFacet', SBDAddress),
    ClanFacet: await hre.ethers.getContractAt('ClanFacet', SBDAddress),
    ItemsFacet: await hre.ethers.getContractAt('ItemsFacet', SBDAddress),
    KnightFacet: await hre.ethers.getContractAt('KnightFacet', SBDAddress),
    TournamentFacet: await hre.ethers.getContractAt('TournamentFacet', SBDAddress),
    TreasuryFacet: await hre.ethers.getContractAt('TreasuryFacet', SBDAddress),
    SBVHookFacet: await hre.ethers.getContractAt('SBVHookFacet', SBDAddress),
    Address: SBDAddress
  }
}