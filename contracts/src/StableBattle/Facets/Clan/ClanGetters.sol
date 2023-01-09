// SPDX-License-Identifier: Unlicensed

pragma solidity ^0.8.0;

import { Clan, Proposal } from "../../Meta/DataStructures.sol";
import { ClanStorage } from "../Clan/ClanStorage.sol";

abstract contract ClanGetters {
  using ClanStorage for ClanStorage.State;

  function _clanInfo(uint clanId) internal view virtual returns(Clan memory) {
    return ClanStorage.state().clan[clanId];
  }

  function _clanLeader(uint clanId) internal view virtual returns(uint256) {
    return ClanStorage.state().clan[clanId].leader;
  }

  function _clanTotalMembers(uint clanId) internal view virtual returns(uint) {
    return ClanStorage.state().clan[clanId].totalMembers;
  }
  
  function _clanStake(uint clanId) internal view virtual returns(uint256) {
    return ClanStorage.state().clan[clanId].stake;
  }

  function _clanLevel(uint clanId) internal view virtual returns(uint) {
    return ClanStorage.state().clan[clanId].level;
  }

  function _stakeOf(address benefactor, uint clanId) internal view virtual returns(uint256) {
    return ClanStorage.state().stake[benefactor][clanId];
  }

  function _clanLevelThreshold(uint level) internal view virtual returns (uint) {
    return ClanStorage.state().levelThresholds[level];
  }

  function _clanMaxLevel() internal view virtual returns (uint) {
    return ClanStorage.state().levelThresholds.length;
  }

  function _proposal(uint256 knightId, uint256 clanId) internal view virtual returns(Proposal) {
    return ClanStorage.state().proposal[knightId][clanId];
  }

  function _clansInTotal() internal view virtual returns(uint256) {
    return ClanStorage.state().clansInTotal;
  }
}