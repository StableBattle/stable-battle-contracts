// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.10;

import { LibDiamond } from "../Diamond/LibDiamond.sol";
import { Coin, Pool, Role } from "../Meta/DataStructures.sol";

import { ClanStorage } from "../Facets/Clan/ClanStorage.sol";
import { KnightStorage } from "../Facets/Knight/KnightStorage.sol";
import { MetaStorage } from "../Meta/MetaStorage.sol";
import { TournamentStorage } from "../Facets/Tournament/TournamentStorage.sol";
import { TreasuryStorage } from "../Facets/Treasury/TreasuryStorage.sol";
import { GearStorage } from "../Facets/Gear/GearStorage.sol";
import { AccessControlStorage } from "../Facets/AccessControl/AccessControlStorage.sol";

import { IERC1155 } from "@openzeppelin/contracts/interfaces/IERC1155.sol";
import { IERC165 } from "@openzeppelin/contracts/interfaces/IERC165.sol";
import { IERC173 } from "../Facets/Ownership/IERC173.sol";
import { IDiamondCut } from "../Facets/DiamondCut/IDiamondCut.sol";
import { IDiamondLoupe } from "../Facets/DiamondLoupe/IDiamondLoupe.sol";

contract SBInit {
  struct Args {
    address AAVE_address;

    address USDT_address;
    address USDC_address;
    address EURS_address;

    address AAVE_USDT_address;
    address AAVE_USDC_address;
    address AAVE_EURS_address;

    address SBT_address;
    address SBV_address;
  }

  function SB_init(Args memory _args) external {
  // Assign supported interfaces
    LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
    ds.supportedInterfaces[type(IERC165).interfaceId] = true;
    ds.supportedInterfaces[type(IERC173).interfaceId] = true;
    ds.supportedInterfaces[type(IDiamondCut).interfaceId] = true;
    ds.supportedInterfaces[type(IDiamondLoupe).interfaceId] = true;
    ds.supportedInterfaces[type(IERC1155).interfaceId] = true;

  // Assign Meta Storage
    // Token & Villages
      MetaStorage.state().SBT = _args.SBT_address;
      MetaStorage.state().SBV = _args.SBV_address;
    //AAVE
    MetaStorage.state().pool[Pool.AAVE] = _args.AAVE_address;
    
    MetaStorage.state().coin[Coin.USDT] = _args.USDT_address;
    MetaStorage.state().coin[Coin.USDC] = _args.USDC_address;
    MetaStorage.state().coin[Coin.EURS] = _args.EURS_address;
    
    MetaStorage.state().acoin[Coin.USDT] = _args.AAVE_USDT_address;
    MetaStorage.state().acoin[Coin.USDC] = _args.AAVE_USDC_address;
    MetaStorage.state().acoin[Coin.EURS] = _args.AAVE_EURS_address;

    MetaStorage.state().compatible[Pool.AAVE][Coin.USDT] = true;
    MetaStorage.state().compatible[Pool.AAVE][Coin.USDC] = true;
    //Test
    MetaStorage.state().compatible[Pool.TEST][Coin.TEST] = true;

  //Knight facet
    //Knight enumeration begins from type(uint256).max
    ///for better compactibility with adding new item types in the future
    KnightStorage.state().knightPrice[Coin.USDT] = 1e9;
    KnightStorage.state().knightPrice[Coin.USDC] = 1e9;

  //Gear Facet
    //all items in [256, 1e12) are gear
    GearStorage.state().gearRangeLeft = 256; //type(uint8).max + 1 See unequipGear in GearFacet
    GearStorage.state().gearRangeRight = 1e12;
  
  //Totem Facet
    //all items in [1e12, 2e12) are totems
    //TotemStorage.state().totemRangeLeft = 1e12;
    //TotemStorage.state().totemRangeRight = 2e12;

  //Items & ERC1155 Facet
    //ERC1155MetadataStorage.layout()._uri = "ex_uri";

  //Clan Facet
    ClanStorage.state().MAX_CLAN_MEMBERS = 10;
    ClanStorage.state().levelThresholds = [0, 100, 200, 300, 400, 500, 600, 700, 800, 900];

  //Treasury Facet
    TreasuryStorage.state().castleTax = 37;
    TreasuryStorage.state().lastBlock = block.number;
    TreasuryStorage.state().rewardPerBlock = 100;

  //AccessControl Facet
    AccessControlStorage.state().role[0xFcB5320ad1C7c5221709A2d25bAdcb64B1ffF860] = Role.ADMIN;
  }
}