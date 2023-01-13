// SPDX-License-Identifier: Unlicensed

pragma solidity ^0.8.0;

import { Clan, ClanRole } from "../../Meta/DataStructures.sol";
import { ClanStorage } from "../Clan/ClanStorage.sol";
import { IClanGetters } from "../Clan/IClan.sol";

abstract contract ClanGetters {
  function _clanInfo(uint clanId) internal view returns(Clan memory) {
    return ClanStorage.state().clan[clanId];
  }

  function _clanLeader(uint clanId) internal view returns(uint256) {
    return ClanStorage.state().clan[clanId].leader;
  }

  function _clanTotalMembers(uint clanId) internal view returns(uint) {
    return ClanStorage.state().clan[clanId].totalMembers;
  }
  
  function _clanStake(uint clanId) internal view returns(uint256) {
    return ClanStorage.state().clan[clanId].stake;
  }

  function _clanLevel(uint clanId) internal view returns(uint) {
    return ClanStorage.state().clan[clanId].level;
  }

  function _clanLevel2(uint256 clanId) internal view returns(uint) {
    uint256 stake = _clanStake(clanId);
    uint[] memory thresholds = ClanStorage.state().levelThresholds;
    uint maxLevel = thresholds.length;
    uint newLevel = 0;
    while(stake > thresholds[newLevel] && newLevel < maxLevel) {
      newLevel++;
    }
    return newLevel;
  }

  function _stakeOf(address benefactor, uint clanId) internal view returns(uint256) {
    return ClanStorage.state().stake[benefactor][clanId];
  }

  function _clanLevelThreshold(uint level) internal view returns (uint) {
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

  function _clanMaxMembers(uint256 clanId) internal view returns(uint) {
    return ClanStorage.state().maxMembers[_clanLevel(clanId)];
  }

  function _clanKickCooldown(uint256 knightId) internal view returns(uint) {
    return ClanStorage.state().clanKickCooldown[knightId];
  }
}

abstract contract ClanGettersExternal is IClanGetters, ClanGetters {
  function getClanLeader(uint clanId) external view returns(uint256) {
    return _clanLeader(clanId);
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

  function getStakeOf(address benefactor, uint clanId) external view returns(uint256) {
    return _stakeOf(benefactor, clanId);
  }

  function getClanLevelThreshold(uint level) external view returns(uint) {
    return _clanLevelThreshold(level);
  }

  function getClanMaxLevel() external view returns(uint) {
    return _clanMaxLevel();
  }

  function getClanJoinProposal(uint256 knightId) external view returns(uint256) {
    return _clanJoinProposal(knightId);
  }
}