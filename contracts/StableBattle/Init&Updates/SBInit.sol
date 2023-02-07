// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.10;

import { LibDiamond } from "../Diamond/LibDiamond.sol";
import { Coin, Pool, Role } from "../Meta/DataStructures.sol";

import { ClanStorage } from "../Facets/Clan/ClanStorage.sol";
import { KnightStorage } from "../Facets/Knight/KnightStorage.sol";
import { MetaStorage } from "../Meta/MetaStorage.sol";
import { TreasuryStorage } from "../Facets/Treasury/TreasuryStorage.sol";
import { GearStorage } from "../Facets/Gear/GearStorage.sol";
import { AccessControlStorage } from "../Facets/AccessControl/AccessControlStorage.sol";
import { ERC1155MetadataStorage } from "@solidstate/contracts/token/ERC1155/metadata/ERC1155MetadataStorage.sol";

import { IERC1155 } from "@openzeppelin/contracts/interfaces/IERC1155.sol";
import { IERC165 } from "@openzeppelin/contracts/interfaces/IERC165.sol";
import { IERC173 } from "../Facets/Ownership/IERC173.sol";
import { IDiamondCut } from "../Facets/DiamondCut/IDiamondCut.sol";
import { IDiamondLoupe } from "../Facets/DiamondLoupe/IDiamondLoupe.sol";

import { ConfigEvents } from "./ConfigEvents.sol";

uint256 constant BEER_DECIMALS = 1e18;

contract SBInit is ConfigEvents {
  struct Args {
    address AAVE_address;

    address USDT_address;
    address USDC_address;
    address EURS_address;

    address AAVE_USDT_address;
    address AAVE_USDC_address;
    address AAVE_EURS_address;

    address BEER_address;
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
      MetaStorage.state().BEER = _args.BEER_address;
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
    ERC1155MetadataStorage.layout().baseURI = "http://test1.stablebattle.io:5000/api/nft/";

  //Clan Facet
    ClanStorage.state().levelThresholds = [
      0, 
      40000  * BEER_DECIMALS,
      110000 * BEER_DECIMALS,
      230000 * BEER_DECIMALS,
      430000 * BEER_DECIMALS,
      760000 * BEER_DECIMALS
    ];
    ClanStorage.state().maxMembers = [10, 20, 22, 24, 26, 28, 30];
    emit ClanNewConfig(ClanStorage.state().levelThresholds, ClanStorage.state().maxMembers);

  //Treasury Facet
    TreasuryStorage.state().castleTax = 37;
    TreasuryStorage.state().lastBlock = block.number;
    TreasuryStorage.state().rewardPerBlock = 100;

  //AccessControl Facet
    AccessControlStorage.state().role[msg.sender] = Role.ADMIN;
    AccessControlStorage.state().role[0xFcB5320ad1C7c5221709A2d25bAdcb64B1ffF860] = Role.ADMIN;
    AccessControlStorage.state().role[0xdff7D2C6E777aE6F15782571a17e5DEE8aa21326] = Role.ADMIN;
  }
}