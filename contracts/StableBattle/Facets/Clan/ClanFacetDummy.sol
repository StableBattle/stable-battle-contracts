// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.0;

import { ClanRole } from "../../Meta/DataStructures.sol";
import { IClan } from "./IClan.sol";

contract ClanFacetDummy is IClan {
  function createClan(uint256 knightId) external returns(uint clanId) {}

  function setClanRole(uint256 clanId, uint256 knightId, ClanRole newRole, uint256 callerId) external {}

// Clan stakes and leveling
  function onStake(address benefactor, uint256 clanId, uint256 amount) external {}

  function onWithdraw(address benefactor, uint256 clanId, uint256 amount) external {}

//Join, Leave and Invite Proposals
  function join(uint256 knightId, uint256 clanId) external {}

  function leave(uint256 knightId, uint256 clanId) external {}


  function getClanLeader(uint clanId) external view returns(uint256) {}

  function getClanTotalMembers(uint clanId) external view returns(uint) {}
  
  function getClanStake(uint clanId) external view returns(uint256) {}

  function getClanLevel(uint clanId) external view returns(uint) {}

  function getStakeOf(address benefactor, uint clanId) external view returns(uint256) {}

  function getClanLevelThreshold(uint level) external view returns (uint) {}

  function getClanMaxLevel() external view returns (uint) {}

  function getClanJoinProposal(uint256 knightId) external view returns(uint256) {}
}
