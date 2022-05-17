// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.0;

import {IERC20} from "../../shared/interfaces/IERC20.sol";
import {IERC721} from "../../shared/interfaces/IERC721.sol";

contract Treasury {
  uint reward_per_block;
  //character_id => amount
  mapping (uint => uint) rewards;
  uint castle_trasury;
  uint last_block;

  IERC721 Villages = IERC721(address(0));
  IERC20 SBT = IERC20(address(0));
  
  function claim_rewards {
    uint payment_cycles = block.number - last_block;
    for (for v = 0; v < Villages.TotalSupply; v++){
        SBT._mint(Villages.ownerOf(v), reward_per_block * payment_cycles * castle_tax);
    }
    SBT._mint(Clan_owners[CastleHolder], reward_per_block * payment_cycles * (1 - castle_tax));
    last_block = block.number;
  }

}