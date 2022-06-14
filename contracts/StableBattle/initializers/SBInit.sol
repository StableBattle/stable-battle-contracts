// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.0;

import { IERC165 } from "../../shared/interfaces/IERC165.sol";
import { IERC173 } from "../../shared/interfaces/IERC173.sol";
import { LibDiamond } from "../../shared/libraries/LibDiamond.sol";
import { IDiamondCut } from "../../shared/interfaces/IDiamondCut.sol";
import { IDiamondLoupe } from "../../shared/interfaces/IDiamondLoupe.sol";
import { IERC1155 } from "../../shared/interfaces/IERC1155.sol";

import { AppStorage, Knight, Clan } from "../libraries/LibAppStorage.sol";
import { IERC20 } from "../../shared/interfaces/IERC20.sol";
import { ISBV } from "../../shared/interfaces/ISBV.sol";
import { IPool } from "@aave/core-v3/contracts/interfaces/IPool.sol";
import { ISBT } from "../../shared/interfaces/ISBT.sol";
import { IItems } from "../../shared/interfaces/IItems.sol";

contract SBInit {

  AppStorage internal s;

  struct Args {
    address USDT_address;
    address AAVE_address;
    address SBT_address;
    address SBV_address;
    address Items_address;

    uint256 knight_offset;
    
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

    //Various contract addresses
      s.USDT = IERC20(_args.USDT_address);
      s.AAVE = IPool(_args.AAVE_address);
      s.SBT = ISBT(_args.SBT_address);
      s.SBV = ISBV(_args.SBV_address);

    //Knight facet
      s.knight_offset = _args.knight_offset;

    //ERC1155 Facet
      s._uri = _args.uri;

    //Clan Facet
      s.MAX_CLAN_MEMBERS = _args.MAX_CLAN_MEMBERS;
      s.levelThresholds = _args.levelThresholds;

    //Treasury Facet
      s.castle_tax = 37;
      s.last_block = block.number;
      s.reward_per_block = 100;
      s.reward_per_block = _args.reward_per_block;
  }
}
