// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.0;

import { ClanRole } from "../../Meta/DataStructures.sol";

interface IClanEvents {
  event ClanCreated(uint clanId, uint256 knightId);
  event ClanAbandoned(uint clanId, uint256 knightId);
  event ClanNewRole(uint clanId, uint256 knightId, ClanRole newRole);
  event ClanNewName(uint256 clanId, string newClanName);
  event ClanNewLevel(uint256 clanId, uint256 newLevel);

  event ClanStakeAdded(address user, uint clanId, uint amount, uint256 clanStakeTotal, uint256 walletStakeTotal);
  event ClanStakeWithdrawRequest(address user, uint256 clanId, uint256 amount, uint256 cooldownEnd);
  event ClanStakeWithdrawn(address user, uint clanId, uint amount, uint256 clanStakeTotal, uint256 walletStakeTotal);
  event ClanLeveledUp(uint clanId, uint newLevel);
  event ClanLeveledDown(uint clanId, uint newLevel);

  event ClanJoinProposalSent(uint clanId, uint256 knightId);
  event ClanJoinProposalWithdrawn(uint clanId, uint256 knightId);
  event ClanJoinProposalAccepted(uint clanId, uint256 knightId, uint256 callerId);
  event ClanJoinProposalDismissed(uint clanId, uint256 knightId);
  event ClanKnightKicked(uint clanId, uint256 knightId, uint256 callerId);
  event ClanKnightLeft(uint clanId, uint256 knightId);
  event ClanKnightQuit(uint clanId, uint256 knightId);
  event ClanKnightJoined(uint clanId, uint256 knightId);
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
  error ClanModifiers_ClanNameTaken(string clanName);
  error ClanModifiers_ClanNameWrongLength(string clanName);
  error ClanModifiers_UserOnWithdrawalCooldown(address user);
  error ClanModifiers_WithdrawalAmountAboveStake(uint256 clanId, address user, uint256 withdrawalAmount);
  error ClanModifiers_NotClanOwner(uint256 knightId);
  error ClanModifiers_WithdrawalAbovePending(uint256 clanId, address user, uint256 withdrawalAmount);

  error ClanFacet_InsufficientStake(uint256 stakeAvalible, uint256 withdrawAmount);
  error ClanFacet_CantJoinAlreadyInClan(uint256 knightId, uint256 clanId);
  error ClanFacet_NoProposalOrNotClanLeader(uint256 knightId, uint256 clanId);
  error ClanFacet_CantKickThisMember(uint256 knightId, uint256 clanId, uint256 kickerId);
  error ClanFacet_CantJoinOtherClanWhileBeingAClanLeader(uint256 knightId, uint256 clanId, uint256 kickerId);
  error ClanFacet_CantAssignNewRoleToThisCharacter(uint256 clanId, uint256 knightId, ClanRole newRole, uint256 callerId);
  error ClanFacet_NoJoinProposal(uint256 knightId, uint256 clanId);
  error ClanFacet_InsufficientRolePriveleges(uint256 callerId);
}

interface IClanGetters {
  function getClanLeader(uint clanId) external view returns(uint256);

  function getClanRole(uint knightId) external view returns(ClanRole);

  function getClanTotalMembers(uint clanId) external view returns(uint);
  
  function getClanStake(uint clanId) external view returns(uint256);

  function getClanLevel(uint clanId) external view returns(uint);

  function getStakeOf(uint clanId, address user) external view returns(uint256);

  function getClanLevelThreshold(uint level) external view returns(uint);

  function getClanMaxLevel() external view returns(uint);

  function getClanJoinProposal(uint256 knightId) external view returns(uint256);

  function getClanInfo(uint clanId) external view returns(uint256, uint256, uint256, uint256);

  function getClanConfig() 
    external
    view
    returns(
      uint256[] memory,
      uint256[] memory,
      uint,
      uint,
      uint
    );

  function getClanKnightInfo(uint knightId) external view returns(uint256, uint256, ClanRole, uint256);
  
  function getClanName(uint256 clanId) external view returns(string memory);

  function getClanNameTaken(string calldata clanName) external view returns(bool);

  function getClanUserInfo(uint256 clanId, address user) external view returns(uint256, uint256, uint256);

  function getClansInTotal() external view returns(uint256);
}

interface IClan is IClanGetters, IClanEvents, IClanErrors {
  function createClan(uint256 knightId, string calldata clanName) external returns(uint256);

  function abandonClan(uint256 clanId, uint256 ownerId) external;

  function setClanRole(uint256 clanId, uint256 knightId, ClanRole newRole, uint256 callerId) external;

  function setClanName(uint256 clanId, string calldata newClanName) external;

// Clan stakes and leveling
  function clanStake(uint256 clanId, uint256 amount) external;

  function clanWithdraw(uint256 clanId, uint256 amount) external;

  function clanWithdrawRequest(uint256 clanId, uint256 amount) external;

//Join, Leave and Invite Proposals
  function joinClan(uint256 knightId, uint256 clanId) external;

  function withdrawJoinClan(uint256 knightId, uint256 clanId) external;

  function approveJoinClan(uint256 knightId, uint256 clanId, uint256 callerId) external;

  function dismissJoinClan(uint256 knightId, uint256 clanId, uint256 callerId) external;
  
  function kickFromClan(uint256 knightId, uint256 clanId, uint256 callerId) external;

  function leaveClan(uint256 knightId, uint256 clanId) external;
}
