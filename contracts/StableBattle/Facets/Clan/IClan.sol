// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.0;

import { ClanRole } from "../../Meta/DataStructures.sol";

interface IClanEvents {
  event ClanCreated(uint clanId, uint256 knightId);
  event ClanAbandoned(uint clanId, uint256 knightId);
  event ClanLeaderChanged(uint clanId, uint256 knightId);
  event NewClanRole(uint clanId, uint256 knightId, ClanRole newRole);

  event StakeAdded(address benefactor, uint clanId, uint amount);
  event StakeWithdrawn(address benefactor, uint clanId, uint amount);
  event ClanLeveledUp(uint clanId, uint newLevel);
  event ClanLeveledDown(uint clanId, uint newLevel);

  event KnightAskedToJoin(uint clanId, uint256 knightId);
  event KnightNoLongerWantsToJoin(uint clanId, uint256 knightId);
  event KnightJoinedClan(uint clanId, uint256 knightId);
  event KnightJoinDismissed(uint clanId, uint256 knightId);
  event KnightAskedToLeave(uint clanId, uint256 knightId);
  event KnightLeftClan(uint clanId, uint256 knightId);
  event KnightInvitedToClan(uint clanId, uint256 knightId);
}

interface IClanErrors {
  error ClanModifiers_ClanDoesntExist(uint256 clanId);
  error ClanModifiers_KnightIsNotClanLeader(uint256 knightId, uint256 clanId);
  error ClanModifiers_KnightIsClanLeader(uint256 knightId, uint256 clanId);
  error ClanModifiers_KnightInSomeClan(uint256 knightId, uint256 clanId);
  error ClanModifiers_KnightOnClanActivityCooldown(uint256 knightId);
  error ClanModifiers_KnightNotInThisClan(uint256 knightId, uint256 clanId);
  error ClanModifiers_AboveMaxMembers(uint256 clanId);
  error ClanModifiers_JoinProposalToSomeClanExists(uint256 knightId, uint256 clanId);
  error ClanModifiers_KickingMembersOnCooldownForThisKnight(uint256 knightId);
  error ClanModifiers_ClanOwnersCantCallThis(uint256 knightId);

  error ClanFacet_InsufficientStake(uint256 stakeAvalible, uint256 withdrawAmount);
  error ClanFacet_CantJoinAlreadyInClan(uint256 knightId, uint256 clanId);
  error ClanFacet_NoProposalOrNotClanLeader(uint256 knightId, uint256 clanId);
  error ClanFacet_CantKickThisMember(uint256 knightId, uint256 clanId, uint256 kickerId);
  error ClanFacet_CantJoinOtherClanWhileBeingAClanLeader(uint256 knightId, uint256 clanId, uint256 kickerId);
  error ClanFacet_CantAssignNewRoleToThisCharacter(uint256 clanId, uint256 knightId, ClanRole newRole, uint256 callerId);
  error ClanFacet_NoJoinProposal(uint256 knightId, uint256 clanId);
}

interface IClanGetters {
  function getClanLeader(uint clanId) external view returns(uint256);

  function getClanTotalMembers(uint clanId) external view returns(uint);
  
  function getClanStake(uint clanId) external view returns(uint256);

  function getClanLevel(uint clanId) external view returns(uint);

  function getStakeOf(address benefactor, uint clanId) external view returns(uint256);

  function getClanLevelThreshold(uint level) external view returns (uint);

  function getClanMaxLevel() external view returns (uint);

  function getClanJoinProposal(uint256 knightId) external view returns(uint256);
}

interface IClan is IClanGetters, IClanEvents, IClanErrors {
  function createClan(uint256 knightId) external returns(uint clanId);

  function setClanRole(uint256 clanId, uint256 knightId, ClanRole newRole, uint256 callerId) external;

// Clan stakes and leveling
  function onStake(address benefactor, uint256 clanId, uint256 amount) external;

  function onWithdraw(address benefactor, uint256 clanId, uint256 amount) external;

//Join, Leave and Invite Proposals
  function join(uint256 knightId, uint256 clanId) external;

  function leave(uint256 knightId, uint256 clanId) external;
}
