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
import { IBEER } from "../../BEER/IBEER.sol";

import { ConfigEvents } from "./ConfigEvents.sol";

uint constant ONE_HOUR_IN_SECONDS = 60 * 60;
uint constant TWO_DAYS_IN_SECONDS = 2 * 24 * 60 * 60;
uint constant TWO_WEEKS_IN_SECONDS = 60 * 60 * 24 * 14;


library OldMetaStorage {
  struct State {
    // StableBattle EIP20 Token address
    address SBT;
    // StableBattle EIP721 Village address
    address SBV;

    mapping (Pool => address) pool;
    mapping (Coin => address) coin;
    mapping (Pool => mapping (Coin => bool)) compatible;
    mapping (Coin => address) acoin;

    mapping (address => bool) admins;
  }

  bytes32 internal constant STORAGE_SLOT = keccak256("Meta.storage");

  function state() internal pure returns (State storage l) {
    bytes32 slot = STORAGE_SLOT;
    assembly {
      l.slot := slot
    }
  }
}

contract SBUpgrade_0_0_6_to_0_0_18 is ConfigEvents {
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

  function SB_update(Args memory _args) external {
  // Just in case null hanging storage values from old meta storage
    OldMetaStorage.state().admins[msg.sender] = false;
    uint256 BEER_DECIMALS = IBEER(_args.BEER_address).decimals();
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
      40000  * (10 ** BEER_DECIMALS),
      110000 * (10 ** BEER_DECIMALS),
      230000 * (10 ** BEER_DECIMALS),
      430000 * (10 ** BEER_DECIMALS),
      760000 * (10 ** BEER_DECIMALS)
    ];
    ClanStorage.state().maxMembers = [10, 20, 22, 24, 26, 28, 30];
    ClanStorage.state().clanActivityCooldownConst = TWO_DAYS_IN_SECONDS;
    ClanStorage.state().clanKickCoolDownConst = ONE_HOUR_IN_SECONDS;
    ClanStorage.state().clanStakeWithdrawCooldownConst = TWO_WEEKS_IN_SECONDS;

    emit ClanNewConfig(
      ClanStorage.state().levelThresholds,
      ClanStorage.state().maxMembers,
      ClanStorage.state().clanActivityCooldownConst,
      ClanStorage.state().clanKickCoolDownConst,
      ClanStorage.state().clanStakeWithdrawCooldownConst
    );

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