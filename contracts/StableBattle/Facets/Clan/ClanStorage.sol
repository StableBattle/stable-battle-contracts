// SPDX-License-Identifier: Unlicensed

pragma solidity ^0.8.0;

import { Clan, ClanRole } from "../../Meta/DataStructures.sol";
import { EnumerableMap } from "@openzeppelin/contracts/utils/structs/EnumerableMap.sol";

library ClanStorage {
  struct State {
    uint[] levelThresholds;
    uint[] maxMembers;
    uint256 clansInTotal;

    //Clan => clan leader id
    mapping(uint256 => uint256) clanLeader;
    //Clan => stake amount
    mapping(uint256 => uint256) clanStake;
    //Clan => amount of members in clanId
    mapping(uint256 => uint256) clanTotalMembers;
    //Clan => level of clanId
    mapping(uint256 => uint256) clanLevel;
    //Clan => name of said clan
    mapping(uint256 => string) clanName;
    //Clan name => taken or not
    mapping(string => bool) clanNameTaken;
    
    //Knight => id of clan where join proposal is sent
    mapping (uint256 => uint256) joinProposal;
    //Knight => end of cooldown
    mapping(uint256 => uint256) clanActivityCooldown;
    //Knight => clan join proposal sent
    mapping(uint256 => bool) joinProposalPending;
    //Kinight => Role in clan
    mapping(uint256 => ClanRole) roleInClan;
    //Knight => kick cooldown duration
    mapping(uint256 => uint) clanKickCooldown;

    //address => clanId => amount
    mapping (address => mapping (uint => uint256)) stake;
    //clanId => address => withdrawal cooldown
    mapping (uint256 => mapping (address => uint256)) withdrawalCooldown;
    //clanId => user => withdrawal
    mapping (uint256 => EnumerableMap.AddressToUintMap) pendingWithdrawal;
  }

  bytes32 internal constant STORAGE_SLOT = keccak256("Clan.storage");

  function state() internal pure returns (State storage l) {
    bytes32 slot = STORAGE_SLOT;
    assembly {
      l.slot := slot
    }
  }
}