// SPDX-License-Identifier: Unlicensed

pragma solidity ^0.8.0;

import { ClanRole } from "../../Meta/DataStructures.sol";
import { ClanStorage } from "../Clan/ClanStorage.sol";
import { IClanGetters } from "../Clan/IClan.sol";
import { EnumerableMap } from "openzeppelin-contracts/utils/structs/EnumerableMap.sol";

abstract contract ClanConfigGetters {
  function _clanActivityCooldownConst() internal view returns(uint) {
    return ClanStorage.state().clanActivityCooldownConst;
  }

  function _clanKickCoolDownConst() internal view returns(uint) {
    return ClanStorage.state().clanKickCoolDownConst;
  }

  function _clanStakeWithdrawCooldownConst() internal view returns(uint) {
    return ClanStorage.state().clanStakeWithdrawCooldownConst;
  }
}

abstract contract ClanGetters is ClanConfigGetters {
  using EnumerableMap for EnumerableMap.AddressToUintMap;
  function _clanInfo(uint clanId) internal view returns(uint256, uint256, uint256, uint256) {
    return (
      _clanLeader(clanId),
      _clanStake(clanId),
      _clanTotalMembers(clanId),
      _clanLevel(clanId));
  }

  function _clanLeader(uint clanId) internal view returns(uint256) {
    return ClanStorage.state().clanLeader[clanId];
  }

  function _clanTotalMembers(uint clanId) internal view returns(uint) {
    return ClanStorage.state().clanTotalMembers[clanId];
  }
  
  // Returns the total clan stake, minus any pending withdrawals
  function _clanStake(uint clanId) internal view returns(uint256) {
    uint256 stake = ClanStorage.state().clanStake[clanId];
    uint256 withdrawed = 0;
    uint256 numOfPendingWithdrawals = ClanStorage.state().pendingWithdrawal[clanId].length();
    for(uint256 i; i < numOfPendingWithdrawals; ++i) {
      (address user, uint256 pendingWithdraw) = ClanStorage.state().pendingWithdrawal[clanId].at(i);
      if(_withdrawalCooldown(clanId, user) <= block.timestamp) {
        withdrawed += pendingWithdraw;
      }
    }
    return stake - withdrawed;
  }

  function _clanLevel(uint256 clanId) internal view returns(uint) {
    uint256 stake = _clanStake(clanId);
    uint[] memory thresholds = ClanStorage.state().levelThresholds;
    uint maxLevel = thresholds.length;
    for(uint newLevel = 1; newLevel < maxLevel; newLevel++) {
      if(stake < thresholds[newLevel]) {
        return newLevel;
      }
    }
    return maxLevel;
  }

  function _clanLevelThresholds() internal view returns (uint[] memory) {
    return ClanStorage.state().levelThresholds;
  }

  function _clanLevelThreshold(uint256 level) internal view returns (uint) {
    return ClanStorage.state().levelThresholds[level];
  }

  function _clanMaxLevel() internal view returns (uint) {
    return ClanStorage.state().levelThresholds.length;
  }

  function _clansInTotal() internal view returns(uint256) {
    return ClanStorage.state().clansInTotal;
  }

  function _clanActivityCooldown(uint256 knightId) internal view returns(uint256) {
    return ClanStorage.state().clanActivityCooldown[knightId];
  }

  function _clanJoinProposal(uint256 knightId) internal view returns(uint256) {
    return ClanStorage.state().joinProposal[knightId];
  }

  function _roleInClan(uint256 knightId) internal view returns(ClanRole) {
    return ClanStorage.state().roleInClan[knightId];
  }

  function _clanKickCooldown(uint256 knightId) internal view returns(uint) {
    return ClanStorage.state().clanKickCooldown[knightId];
  }

  function _clanName(uint256 clanId) internal view returns(string memory) {
    return ClanStorage.state().clanName[clanId];
  }

  function _clanNameTaken(string calldata clanName) internal view returns(bool) {
    return ClanStorage.state().clanNameTaken[clanName];
  }

  function _clanMaxMembers() internal view returns(uint256[] memory) {
    return ClanStorage.state().maxMembers;
  }

  function _clanMaxMembers(uint256 clanId) internal view returns(uint256) {
    return ClanStorage.state().maxMembers[_clanLevel(clanId) - 1];
  }

  function _stakeOf(uint clanId, address user) internal view returns(uint256) {
    return ClanStorage.state().stake[user][clanId];
  }

  function _pendingWithdrawal(uint256 clanId, address user) internal view returns(uint256) {
    (bool exists, uint256 amount) = ClanStorage.state().pendingWithdrawal[clanId].tryGet(user);
    return exists ? amount : 0;
  }

  function _withdrawalCooldown(uint256 clanId, address user) internal view returns(uint256) {
    return ClanStorage.state().withdrawalCooldown[clanId][user];
  }
}

abstract contract ClanGettersExternal is IClanGetters, ClanGetters {
  function getClanLeader(uint clanId) external view returns(uint256) {
    return _clanLeader(clanId);
  }

  function getClanRole(uint knightId) external view returns(ClanRole) {
    return _roleInClan(knightId);
  }

  function getClanTotalMembers(uint clanId) external view returns(uint) {
    return _clanTotalMembers(clanId);
  }
  
  function getClanStake(uint clanId) external view returns(uint256) {
    return _clanStake(clanId);
  }

  function getClanLevel(uint clanId) external view returns(uint) {
    return _clanLevel(clanId);
  }

  function getStakeOf(uint clanId, address user) external view returns(uint256) {
    return _stakeOf(clanId, user);
  }

  function getClanLevelThreshold(uint256 level) external view returns(uint) {
    return _clanLevelThreshold(level);
  }

  function getClanLevelThresholds() external view returns(uint[] memory) {
    return _clanLevelThresholds();
  }

  function getClanMaxLevel() external view returns(uint) {
    return _clanMaxLevel();
  }

  function getClanJoinProposal(uint256 knightId) external view returns(uint256) {
    return _clanJoinProposal(knightId);
  }

  function getClanInfo(uint clanId) external view returns(uint256, uint256, uint256, uint256) {
    return (
      _clanLeader(clanId),
      _clanTotalMembers(clanId),
      _clanStake(clanId),
      _clanLevel(clanId)
    );
  }

  function getClanKnightInfo(uint knightId) external view returns(uint256, uint256, ClanRole, uint256) {
    return (
      _clanJoinProposal(knightId),
      _clanActivityCooldown(knightId),
      _roleInClan(knightId),
      _clanKickCooldown(knightId)
    );
  }

  function getClanConfig() 
    external
    view
    returns(
      uint256[] memory,
      uint256[] memory,
      uint,
      uint,
      uint
    )
  {
    return(
      _clanLevelThresholds(),
      _clanMaxMembers(),
      _clanActivityCooldownConst(),
      _clanKickCoolDownConst(),
      _clanStakeWithdrawCooldownConst()
    );
  }

  function getClanName(uint256 clanId) external view returns(string memory) {
    return _clanName(clanId);
  }

  function getClanNameTaken(string calldata clanName) external view returns(bool) {
    return _clanNameTaken(clanName);
  }

  function getClanUserInfo(uint256 clanId, address user) external view returns(uint256, uint256, uint256) {
    return (_stakeOf(clanId, user), _pendingWithdrawal(clanId, user), _withdrawalCooldown(clanId, user));
  }
}