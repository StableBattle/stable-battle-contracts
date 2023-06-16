// SPDX-License-Identifier: Unlicensed

pragma solidity ^0.8.0;

import { Clan, ClanRole } from "../../Meta/DataStructures.sol";
import { EnumerableMap } from "openzeppelin-contracts/utils/structs/EnumerableMap.sol";
import { ClanSetupLib } from "../Clan/ClanSetupLib.sol";

library ClanStorage {
  struct Layout {
    //!!!DEPRECATED TO BE REMOVED ON NEXT WIPE!!!
    uint[] levelThresholds;
    //!!!DEPRECATED TO BE REMOVED ON NEXT WIPE!!!
    uint[] maxMembersPerLevel;
    uint256 clansInTotal;

    //Clan => clan leader id
    mapping(uint256 => uint256) clanLeader;
    //Clan => stake amount
    mapping(uint256 => uint256) clanStake;
    //Clan => amount of members in clanId
    mapping(uint256 => uint256) clanTotalMembers;
    //!!!DEPRECATED TO BE REMOVED ON NEXT WIPE!!!
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

    //Cooldowns
    //!!!DEPRECATED TO BE REMOVED ON NEXT WIPE!!!
    uint256 clanActivityCooldownConst;
    //!!!DEPRECATED TO BE REMOVED ON NEXT WIPE!!!
    uint256 clanKickCoolDownConst;
    //!!!DEPRECATED TO BE REMOVED ON NEXT WIPE!!!
    uint256 clanStakeWithdrawCooldownConst;
  }

  bytes32 internal constant STORAGE_SLOT = keccak256("Clan.storage");

  function layout() internal pure returns (Layout storage l) {
    bytes32 slot = STORAGE_SLOT;
    assembly {
      l.slot := slot
    }
  }

  using EnumerableMap for EnumerableMap.AddressToUintMap;

  // Returns the total clan stake, minus any pending withdrawals
  function clanStake(uint clanId) internal view returns(uint256) {
    uint256 stake = layout().clanStake[clanId];
    uint256 withdrawed = 0;
    uint256 numOfPendingWithdrawals = layout().pendingWithdrawal[clanId].length();
    for(uint256 i; i < numOfPendingWithdrawals; ++i) {
      (address user, uint256 pendingWithdraw) = layout().pendingWithdrawal[clanId].at(i);
      if(layout().withdrawalCooldown[clanId][user] <= block.timestamp) {
        withdrawed += pendingWithdraw;
      }
    }
    return stake - withdrawed;
  }

  function clanLevel(uint256 clanId) internal view returns(uint) {
    uint256 stake = clanStake(clanId);
    uint[] memory thresholds = ClanSetupLib.clanStakeLevelThresholds();
    uint maxLevel = thresholds.length;
    for(uint newLevel = 1; newLevel < maxLevel; newLevel++) {
      if(stake < thresholds[newLevel]) {
        return newLevel;
      }
    }
    return maxLevel;
  }

  function clanMaxMembers(uint256 clanId) internal view returns(uint256) {
    return ClanSetupLib.maxMembersPerLevel()[clanLevel(clanId) - 1];
  }

  function pendingWithdrawal(uint256 clanId, address user) internal view returns(uint256) {
    (bool exists, uint256 amount) = layout().pendingWithdrawal[clanId].tryGet(user);
    return exists ? amount : 0;
  }
}