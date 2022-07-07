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
import { MetaStorage } from "../storage/MetaStorage.sol";
import { TournamentStorage } from "../storage/TournamentStorage.sol";
import { TreasuryStorage } from "../storage/TreasuryStorage.sol";
import { GearStorage, gearSlot } from "../storage/GearStorage.sol";

import { IERC20 } from "../../shared/interfaces/IERC20.sol";
import { ISBV } from "../../shared/interfaces/ISBV.sol";
import { IPool } from "@aave/core-v3/contracts/interfaces/IPool.sol";
import { ISBT } from "../../shared/interfaces/ISBT.sol";
import { IItems } from "../../shared/interfaces/IItems.sol";

contract SBInit {
  using ClanStorage for ClanStorage.Layout;
  using KnightStorage for KnightStorage.Layout;
  using ItemsStorage for ItemsStorage.Layout;
  using MetaStorage for MetaStorage.Layout;
  using TournamentStorage for TournamentStorage.Layout;
  using TreasuryStorage for TreasuryStorage.Layout;
  using GearStorage for GearStorage.Layout;

  struct Args {
    address USDT_address;
    address AAVE_address;
    address SBT_address;
    address SBV_address;
    
    string uri;

    uint MAX_CLAN_MEMBERS;
    uint[] levelThresholds;

    uint reward_per_block;
  }

  function SB_init(Args memory _args) external {
    // Assign supported interfaces
      LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
      ds.supportedInterfaces[type(IERC165).interfaceId] = true;
      ds.supportedInterfaces[type(IERC173).interfaceId] = true;
      ds.supportedInterfaces[type(IDiamondCut).interfaceId] = true;
      ds.supportedInterfaces[type(IDiamondLoupe).interfaceId] = true;
      ds.supportedInterfaces[type(IERC1155).interfaceId] = true;

    //Assign StableBattle Storage
      MetaStorage.layout().USDT = IERC20(_args.USDT_address);
      MetaStorage.layout().AAVE = IPool(_args.AAVE_address);
      MetaStorage.layout().SBT = ISBT(_args.SBT_address);
      MetaStorage.layout().SBV = ISBV(_args.SBV_address);

    //Knight facet
      //all items in [10e12, inf) are knights
      KnightStorage.layout().knightOffset = 1e13;

    //Gear Facet
      //all items in [256, 1e12) are gear
      GearStorage.layout().gearRangeLeft = type(uint8).max + 1; //See unequipGear in GearFacet
      GearStorage.layout().gearRangeRight = 1e12;
    
    //Totem Facet
      //all items in [1e12, 2e12) are totems
      //TotemStorage.layout().totemRangeLeft = 1e12;
      //TotemStorage.layout().totemRangeRight = 2e12;

    //Items & ERC1155 Facet
      ItemsStorage.layout()._uri = _args.uri;

    //Clan Facet
      ClanStorage.layout().MAX_CLAN_MEMBERS = _args.MAX_CLAN_MEMBERS;
      ClanStorage.layout().levelThresholds = _args.levelThresholds;

    //Treasury Facet
      TreasuryStorage.layout().castleTax = 37;
      TreasuryStorage.layout().lastBlock = block.number;
      TreasuryStorage.layout().rewardPerBlock = _args.reward_per_block;

  }
}
