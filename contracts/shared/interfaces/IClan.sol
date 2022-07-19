// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.0;

import { Proposal } from "../../StableBattle/storage/ClanStorage.sol";

interface IClan {
  function create(uint256 knightId) external returns(uint clanId);

  function abandon(uint256 clanId) external;

  function changeLeader(uint256 clanId, uint256 knightId) external;

// Clan stakes and leveling
  function onStake(address benefactor, uint256 clanId, uint256 amount) external;

  function onWithdraw(address benefactor, uint256 clanId, uint256 amount) external;

//Join, Leave and Invite Proposals
  function join(uint256 knightId, uint256 clanId) external;

  function leave(uint256 knightId) external;

  function invite(uint256 knightId, uint256 clanId) external;

//Public getters

  function getClanLeader(uint clanId) external view returns(uint256);

  function getClanTotalMembers(uint clanId) external view returns(uint);
  
  function getClanStake(uint clanId) external view returns(uint256);

  function getClanLevel(uint clanId) external view returns(uint);

  function getStakeOf(address benefactor, uint clanId) external view returns(uint256);

  function getClanLevelThreshold(uint level) external view returns (uint);

  function getClanMaxLevel() external view returns (uint);

  function getProposal(uint256 knightId, uint256 clanId) external view returns (Proposal);

  event ClanCreated(uint clanId, uint256 knightId);
  event ClanAbandoned(uint clanId, uint256 knightId);
  event ClanLeaderChanged(uint clanId, uint256 knightId);

  event StakeAdded(address benefactor, uint clanId, uint amount);
  event StakeWithdrawn(address benefactor, uint clanId, uint amount);
  event ClanLeveledUp(uint clanId, uint newLevel);
  event ClanLeveledDown(uint clanId, uint newLevel);

  event KnightAskedToJoin(uint clanId, uint256 knightId);
  event KnightJoinedClan(uint clanId, uint256 knightId);
  event KnightAskedToLeave(uint clanId, uint256 knightId);
  event KnightLeftClan(uint clanId, uint256 knightId);
  event KnightInvitedToClan(uint clanId, uint256 knightId);
}
