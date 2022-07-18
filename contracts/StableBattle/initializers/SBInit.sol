// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.0;

import { IERC165 } from "../../shared/interfaces/IERC165.sol";
import { IERC173 } from "../../shared/interfaces/IERC173.sol";
import { LibDiamond } from "../../shared/libraries/LibDiamond.sol";
import { IDiamondCut } from "../../shared/interfaces/IDiamondCut.sol";
import { IDiamondLoupe } from "../../shared/interfaces/IDiamondLoupe.sol";
import { IERC1155 } from "../../shared/interfaces/IERC1155.sol";

import { ClanStorage, Clan } from "../storage/ClanStorage.sol";
import { KnightStorage, Knight} from "../storage/KnightStorage.sol";
import { ItemsStorage } from "../storage/ItemsStorage.sol";
import { Coin, Pool, MetaStorage } from "../storage/MetaStorage.sol";
import { TournamentStorage } from "../storage/TournamentStorage.sol";
import { TreasuryStorage } from "../storage/TreasuryStorage.sol";
import { GearStorage, gearSlot } from "../storage/GearStorage.sol";

import { IERC20 } from "../../shared/interfaces/IERC20.sol";
import { ISBV } from "../../shared/interfaces/ISBV.sol";
import { IPool } from "@aave/core-v3/contracts/interfaces/IPool.sol";
import { ISBT } from "../../shared/interfaces/ISBT.sol";
import { IItems } from "../../shared/interfaces/IItems.sol";

contract SBInit {
  using ClanStorage for ClanStorage.State;
  using KnightStorage for KnightStorage.State;
  using ItemsStorage for ItemsStorage.State;
  using MetaStorage for MetaStorage.State;
  using TournamentStorage for TournamentStorage.State;
  using TreasuryStorage for TreasuryStorage.State;
  using GearStorage for GearStorage.State;

  struct Args {
    address USDT_address;
    address USDC_address;
    address AAVE_address;
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
      MetaStorage.state().coin[Coin.USDT] = _args.USDT_address;
      MetaStorage.state().coin[Coin.USDC] = _args.USDC_address;
      MetaStorage.state().pool[Pool.AAVE] = _args.AAVE_address;
      MetaStorage.state().SBT = _args.SBT_address;
      MetaStorage.state().SBV = _args.SBV_address;
    //MetaStorage.state().compatible[Pool.AAVE][Coin.USDT] = true;
      MetaStorage.state().compatible[Pool.AAVE][Coin.USDC] = true;
    //MetaStorage.state().compatible[Pool.TEST][Coin.TEST] = true;

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
      ItemsStorage.state()._uri = "ex_uri";

    //Clan Facet
      ClanStorage.state().MAX_CLAN_MEMBERS = 10;
      ClanStorage.state().levelThresholds = [0, 100, 200, 300, 400, 500, 600, 700, 800, 900];

    //Treasury Facet
      TreasuryStorage.state().castleTax = 37;
      TreasuryStorage.state().lastBlock = block.number;
      TreasuryStorage.state().rewardPerBlock = 100;
  }
}