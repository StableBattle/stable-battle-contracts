// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.0;

import { ClanRole } from "../../Meta/DataStructures.sol";
import { IClan } from "./IClan.sol";

contract ClanFacetDummy is IClan {
  function createClan(uint256 knightId, string calldata clanName) external returns(uint256) {}

  function abandonClan(uint256 clanId, uint256 ownerId) external {}

  function setClanRole(uint256 clanId, uint256 knightId, ClanRole newRole, uint256 callerId) external {}

  function setClanName(uint256 clanId, string calldata newClanName) external {}

// Clan stakes and leveling
  function clanStake(uint256 clanId, uint256 amount) external {}

  function clanWithdraw(uint256 clanId, uint256 amount) external {}

  function clanWithdrawRequest(uint256 clanId, uint256 amount) external {}

//Join, Leave and Invite Proposals
  function joinClan(uint256 knightId, uint256 clanId) external {}

  function withdrawJoinClan(uint256 knightId, uint256 clanId) external {}

  function approveJoinClan(uint256 knightId, uint256 clanId, uint256 callerId) external {}

  function dismissJoinClan(uint256 knightId, uint256 clanId, uint256 callerId) external {}
  
  function kickFromClan(uint256 knightId, uint256 clanId, uint256 callerId) external {}

  function leaveClan(uint256 knightId, uint256 clanId) external {}


  
  function getClanLeader(uint clanId) external view returns(uint256) {}

  function getClanRole(uint knightId) external view returns(ClanRole) {}

  function getClanTotalMembers(uint clanId) external view returns(uint) {}
  
  function getClanStake(uint clanId) external view returns(uint256) {}

  function getClanLevel(uint clanId) external view returns(uint) {}

  function getStakeOf(uint clanId, address user) external view returns(uint256) {}

  function getClanLevelThreshold(uint level) external view returns(uint) {}

  function getClanMaxLevel() external view returns(uint) {}

  function getClanJoinProposal(uint256 knightId) external view returns(uint256) {}

  function getClanInfo(uint clanId) external view returns(uint256, uint256, uint256, uint256) {}

  function getClanConfig() 
    external
    view
    returns(
      uint256[] memory,
      uint256[] memory,
      uint,
      uint,
      uint
    ) {}

  function getClanKnightInfo(uint knightId) external view returns(uint256, uint256, ClanRole, uint256) {}

  function getClanName(uint256 clanId) external view returns(string memory) {}

  function getClanNameTaken(string calldata clanName) external view returns(bool) {}

  function getClanUserInfo(uint256 clanId, address user) external view returns(uint256, uint256, uint256) {}

  function getClansInTotal() external view returns(uint256) {}
}
