// SPDX-License-Identifier: Unlicensed

pragma solidity ^0.8.0;

import { Clan, ClanRole } from "../../Meta/DataStructures.sol";

library ClanStorage {
  struct State {
    uint[] levelThresholds;
    uint[] maxMembers;
    //clanId => clan leader id
    mapping(uint256 => uint256) clanLeader;
    //clanId => stake amount
    mapping(uint256 => uint256) clanStake;
    //clanId => amount of members in clanId
    mapping(uint256 => uint256) clanTotalMembers;
    //clanId => level of clanId
    mapping(uint256 => uint256) clanLevel;

    // knightId => id of clan where join proposal is sent
    mapping (uint256 => uint256) joinProposal;
    // address => clanId => amount
    mapping (address => mapping (uint => uint256)) stake;
    
    uint256 clansInTotal;
    
    //Knight => end of cooldown
    mapping(uint256 => uint256) clanActivityCooldown;
    //Knight => clan join proposal sent
    mapping(uint256 => bool) joinProposalPending;
    //Kinight => Role in clan
    mapping(uint256 => ClanRole) roleInClan;
    //Knight => kick cooldown duration
    mapping(uint256 => uint) clanKickCooldown;
    //Clan => name of said clan
    mapping(uint256 => string) clanName;
    //Clan name => taken or not
    mapping(string => bool) clanNameTaken;
  }

  bytes32 internal constant STORAGE_SLOT = keccak256("Clan.storage");

  function state() internal pure returns (State storage l) {
    bytes32 slot = STORAGE_SLOT;
    assembly {
      l.slot := slot
    }
  }
}