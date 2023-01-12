// SPDX-License-Identifier: Unlicensed

pragma solidity ^0.8.0;

import { Clan, Proposal, ClanRole } from "../../Meta/DataStructures.sol";

library ClanStorage {
  struct State {
    uint MAX_CLAN_MEMBERS;
    uint[] levelThresholds;
    // clanId => Clan
    mapping(uint256 => Clan) clan;
    // knightId => clanId => proposalType
    mapping (uint256 => mapping(uint256 => Proposal)) proposal;
    // address => clanId => amount
    mapping (address => mapping (uint => uint256)) stake;
    
    uint256 clansInTotal;
    
    //Knight => end of cooldown
    mapping(uint256 => uint256) clanActivityCooldown;
    //Knight => clan join proposal sent
    mapping(uint256 => bool) joinProposalPending;
    //Clan => knightId => Role in clan
    mapping(uint256 => mapping(uint256 => ClanRole)) roleInClan;
  }

  bytes32 internal constant STORAGE_SLOT = keccak256("Clan.storage");

  function state() internal pure returns (State storage l) {
    bytes32 slot = STORAGE_SLOT;
    assembly {
      l.slot := slot
    }
  }
}