// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.10;

import { AppStorage, Knight, Clan } from "../libraries/LibAppStorage.sol";

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { IPool } from "@aave/core-v3/contracts/interfaces/IPool.sol";
import { ISBT } from "../../shared/interfaces/ISBT.sol";
import { IERC721Enumerable } from "../../shared/interfaces/IERC721Enumerable.sol";
import { IERC1155 } from "../../shared/interfaces/IERC1155.sol";
import { IItems } from "../../shared/interfaces/IItems.sol";

contract SBInit {   

  AppStorage internal s;

  struct Args {
    address USDT_address;
    address AAVE_address;

    ISBT SBT_;
    IERC721Enumerable SBV_;
    IItems Items_;

    uint256 knight_offset;
    
    string uri;

    uint MAX_CLAN_MEMBERS;
    uint[] levelThresholds;

    address[] beneficiaries;
    uint reward_per_block;
  }

  function SB_init(Args memory _args) external {

    // Various contract addresses
      s.USDT = IERC20(_args.USDT_address);
      s.AAVE = IPool(_args.AAVE_address);

      s.SBT = _args.SBT_;
      s.SBV = _args.SBV_;
      s.Items = _args.Items_;

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
      s.beneficiaries = _args.beneficiaries;
      s.reward_per_block = _args.reward_per_block;
  }
}
