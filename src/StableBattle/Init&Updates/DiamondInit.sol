// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.0;

import { LibDiamond } from "../Diamond/LibDiamond.sol";
import { Coin, Pool, Role } from "../Meta/DataStructures.sol";

import { ClanStorage } from "../Facets/Clan/ClanStorage.sol";
import { KnightStorage } from "../Facets/Knight/KnightStorage.sol";
import { TreasuryStorage } from "../Facets/Treasury/TreasuryStorage.sol";
import { GearStorage } from "../Facets/Gear/GearStorage.sol";
import { AccessControlStorage } from "../Facets/AccessControl/AccessControlStorage.sol";
import { ERC1155MetadataStorage } from "solidstate-solidity/token/ERC1155/metadata/ERC1155MetadataStorage.sol";

import { IERC1155 } from "openzeppelin-contracts/interfaces/IERC1155.sol";
import { IERC165 } from "openzeppelin-contracts/interfaces/IERC165.sol";
import { IERC173 } from "../Facets/Ownership/IERC173.sol";
import { IDiamondCut } from "../Facets/DiamondCut/IDiamondCut.sol";
import { IDiamondLoupe } from "../Facets/DiamondLoupe/IDiamondLoupe.sol";
import { IBEER } from "../../BEER/IBEER.sol";

import { ConfigEvents } from "./ConfigEvents.sol";

import { BEERAddressLib } from "./BEERAddressLib.sol";

uint constant ONE_HOUR_IN_SECONDS = 60 * 60;
uint constant TWO_DAYS_IN_SECONDS = 2 * 24 * 60 * 60;
uint constant TWO_WEEKS_IN_SECONDS = 60 * 60 * 24 * 14;

contract DiamondInit is ConfigEvents {
  function init() external {
    uint256 BEER_DECIMALS = IBEER(BEERAddressLib.BEERAddress).decimals();
  // Assign supported interfaces
    LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
    ds.supportedInterfaces[type(IERC165).interfaceId] = true;
    ds.supportedInterfaces[type(IERC173).interfaceId] = true;
    ds.supportedInterfaces[type(IDiamondCut).interfaceId] = true;
    ds.supportedInterfaces[type(IDiamondLoupe).interfaceId] = true;
    ds.supportedInterfaces[type(IERC1155).interfaceId] = true;

  //Knight facet
    //Knight enumeration begins from type(uint256).max
    ///for better compactibility with adding new item types in the future
    KnightStorage.layout().knightPrice[Coin.USDT] = 1e9;
    KnightStorage.layout().knightPrice[Coin.USDC] = 1e9;

  //Gear Facet
    //all items in [256, 1e12) are gear
    GearStorage.layout().gearRangeLeft = 256; //type(uint8).max + 1 See unequipGear in GearFacet
    GearStorage.layout().gearRangeRight = 1e12;
  
  //Totem Facet
    //all items in [1e12, 2e12) are totems
    //TotemStorage.layout().totemRangeLeft = 1e12;
    //TotemStorage.layout().totemRangeRight = 2e12;

  //Items & ERC1155 Facet
    ERC1155MetadataStorage.layout().baseURI = "http://test1.stablebattle.io:5000/api/nft/";

  //Clan Facet
    ClanStorage.layout().levelThresholds = [
      0,
      40000  * (10 ** BEER_DECIMALS),
      110000 * (10 ** BEER_DECIMALS),
      230000 * (10 ** BEER_DECIMALS),
      430000 * (10 ** BEER_DECIMALS),
      760000 * (10 ** BEER_DECIMALS)
    ];
    ClanStorage.layout().maxMembers = [10, 20, 22, 24, 26, 28, 30];
    ClanStorage.layout().clanActivityCooldownConst = TWO_DAYS_IN_SECONDS;
    ClanStorage.layout().clanKickCoolDownConst = ONE_HOUR_IN_SECONDS;
    ClanStorage.layout().clanStakeWithdrawCooldownConst = TWO_WEEKS_IN_SECONDS;

    emit ClanNewConfig(
      ClanStorage.layout().levelThresholds,
      ClanStorage.layout().maxMembers,
      ClanStorage.layout().clanActivityCooldownConst,
      ClanStorage.layout().clanKickCoolDownConst,
      ClanStorage.layout().clanStakeWithdrawCooldownConst
    );

  //Treasury Facet
    TreasuryStorage.layout().castleTax = 37;
    TreasuryStorage.layout().lastBlock = block.number;
    TreasuryStorage.layout().rewardPerBlock = 100;

  //AccessControl Facet
    AccessControlStorage.layout().role[msg.sender] = Role.ADMIN;
    AccessControlStorage.layout().role[0xFcB5320ad1C7c5221709A2d25bAdcb64B1ffF860] = Role.ADMIN;
    AccessControlStorage.layout().role[0xdff7D2C6E777aE6F15782571a17e5DEE8aa21326] = Role.ADMIN;
  }
}