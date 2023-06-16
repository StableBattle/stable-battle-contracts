// SPDX-License-Identifier: Unlicensed

pragma solidity ^0.8.0;

import { ClanRole } from "../../Meta/DataStructures.sol";
import { ClanStorage } from "../Clan/ClanStorage.sol";
import { IClanGetters } from "../Clan/IClan.sol";
import { EnumerableMap } from "openzeppelin-contracts/utils/structs/EnumerableMap.sol";
import { ClanSetupLib } from "../Clan/ClanSetupLib.sol";

abstract contract ClanGettersExternal is IClanGetters {
  function getClanLeader(uint clanId) external view returns(uint256) {
    return ClanStorage.layout().clanLeader[clanId];
  }

  function getClanRole(uint knightId) external view returns(ClanRole) {
    return ClanStorage.layout().roleInClan[knightId];
  }

  function getClanTotalMembers(uint clanId) external view returns(uint) {
    return ClanStorage.layout().clanTotalMembers[clanId];
  }
  
  function getClanStake(uint clanId) external view returns(uint256) {
    return ClanStorage.clanStake(clanId);
  }

  function getClanLevel(uint clanId) external view returns(uint) {
    return ClanStorage.clanLevel(clanId);
  }

  function getStakeOf(uint clanId, address user) external view returns(uint256) {
    return ClanStorage.layout().stake[user][clanId];
  }

  function getClanLevelThreshold(uint256 level) external pure returns(uint) {
    return ClanSetupLib.clanStakeLevelThresholds()[level];
  }

  function getClanLevelThresholds() external pure returns(uint[] memory) {
    return ClanSetupLib.clanStakeLevelThresholds();
  }

  function getClanMaxLevel() external pure returns(uint) {
    return ClanSetupLib.clanStakeLevelThresholds().length;
  }

  function getClanJoinProposal(uint256 knightId) external view returns(uint256) {
    return ClanStorage.layout().joinProposal[knightId];
  }

  function getClanInfo(uint clanId) external view returns(uint256, uint256, uint256, uint256) {
    return (
      ClanStorage.layout().clanLeader[clanId],
      ClanStorage.layout().clanTotalMembers[clanId],
      ClanStorage.clanStake(clanId),
      ClanStorage.clanLevel(clanId)
    );
  }

  function getClanKnightInfo(uint knightId) external view returns(uint256, uint256, ClanRole, uint256) {
    return (
      ClanStorage.layout().joinProposal[knightId],
      ClanStorage.layout().clanActivityCooldown[knightId],
      ClanStorage.layout().roleInClan[knightId],
      ClanStorage.layout().clanKickCooldown[knightId]
    );
  }

  function getClanConfig() 
    external
    pure
    returns(
      uint256[] memory,
      uint256[] memory,
      uint,
      uint,
      uint
    )
  {
    return(
      ClanSetupLib.clanStakeLevelThresholds(),
      ClanSetupLib.maxMembersPerLevel(),
      ClanSetupLib.clanActivityCooldownConst,
      ClanSetupLib.clanKickCoolDownConst,
      ClanSetupLib.clanStakeWithdrawCooldownConst
    );
  }

  function getClanName(uint256 clanId) external view returns(string memory) {
    return ClanStorage.layout().clanName[clanId];
  }

  function getClanNameTaken(string calldata clanName) external view returns(bool) {
    return ClanStorage.layout().clanNameTaken[clanName];
  }

  function getClanUserInfo(uint256 clanId, address user) external view returns(uint256, uint256, uint256) {
    return (ClanStorage.layout().stake[user][clanId], ClanStorage.pendingWithdrawal(clanId, user), ClanStorage.layout().withdrawalCooldown[clanId][user]);
  }

  function getClansInTotal() external view returns(uint256) {
    return ClanStorage.layout().clansInTotal;
  }
}