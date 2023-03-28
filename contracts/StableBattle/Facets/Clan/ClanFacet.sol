// SPDX-License-Identifier: Unlicensed

pragma solidity ^0.8.0;

import { Clan, ClanRole } from "../../Meta/DataStructures.sol";

import { IClan } from "../Clan/IClan.sol";
import { ClanStorage } from "../Clan/ClanStorage.sol";
import { ClanInternal } from "../Clan/ClanInternal.sol";
import { ItemsModifiers } from "../Items/ItemsModifiers.sol";
import { MetaModifiers } from "../../Meta/MetaModifiers.sol";
import { ClanGettersExternal } from "../Clan/ClanGetters.sol";
import { ExternalCalls } from "../../Meta/ExternalCalls.sol";
import { EnumerableMap } from "@openzeppelin/contracts/utils/structs/EnumerableMap.sol";

contract ClanFacet is
  IClan,
  ItemsModifiers,
  MetaModifiers,
  ClanGettersExternal,
  ClanInternal,
  ExternalCalls
{
  using EnumerableMap for EnumerableMap.AddressToUintMap;
//Creation, Abandonment and Role Change
  /**
  * @dev Creates a new clan.
  * @param knightId The id of the knight to become the clan leader.
  * @param clanName The name of the clan.
  * @return The id of the new clan.
  */
  function createClan(uint256 knightId, string calldata clanName)
    external
    ifOwnsItem(knightId)
    ifIsKnight(knightId)
    ifNotInClan(knightId)
    ifIsNotOnClanActivityCooldown(knightId)
    ifNotClanNameTaken(clanName)
    ifIsClanNameCorrectLength(clanName)
    returns (uint256)
  {
    return _createClan(knightId, clanName);
  }

  // This function allows the owner of a clan to abandon the clan.
  function abandonClan(uint256 clanId, uint256 ownerId)
    external
    ifOwnsItem(ownerId)
    ifIsClanLeader(ownerId, clanId)
  {
    _abandonClan(clanId, ownerId);
  }

  // Set the role of a character in a clan.
  // Only the clan owner can assign the role of clan owner.
  // Only clan owners and admins can assign a role to a character, and can only assign a lower role.
  function setClanRole(uint256 clanId, uint256 knightId, ClanRole newRole, uint256 callerId)
    external
    ifOwnsItem(_clanLeader(clanId))
    ifIsInClan(knightId, clanId)
  {
    ClanRole callerRole = _roleInClan(callerId);
    ClanRole knightRole = _roleInClan(knightId);
    if (newRole == ClanRole.OWNER && callerRole == ClanRole.OWNER) {
      _setClanRole(clanId, callerId, ClanRole.ADMIN);
      _setClanRole(clanId, knightId, ClanRole.OWNER);
    } else if (uint8(callerRole) > uint8(knightRole) && uint8(callerRole) > uint8(newRole)) {
      _setClanRole(clanId, knightId, newRole);
    } else {
      revert ClanFacet_CantAssignNewRoleToThisCharacter(clanId, knightId, newRole, callerId);
    }
  }

  // This function allows a clan leader to change the name of the clan.
  // The clan leader can only change the name of their own clan.
  // A clan's name cannot be changed to another clan's name.
  // A clan's name must be below 30 bytes (usually that means below 30 characters).
  function setClanName(uint256 clanId, string calldata newClanName)
    external
    ifOwnsItem(_clanLeader(clanId))
    ifNotClanNameTaken(newClanName)
    ifIsClanNameCorrectLength(newClanName)
  {
    _setClanName(clanId, newClanName);
  }

// Clan stakes and leveling
  function clanStake(uint256 clanId, uint256 amount)
    external
    ifClanExists(clanId)
  { 
    _clanStake(clanId, amount); 
    BEER().transferFrom(msg.sender, address(this), amount);
  }

  /**
  * @dev Allows a user to request a withdrawal of their clan stake
  * @param clanId the id of the clan to request a withdrawal from
  * @param amount the amount to withdraw
  */
  function clanWithdrawRequest(uint256 clanId, uint256 amount) 
    external
    ifClanExists(clanId)
    ifIsBelowStake(clanId, msg.sender, amount)
  {
    _clanWithdrawRequest(clanId, amount);
  }

  /**
   * @dev Withdraws the given amount of BEER from the clan after withdrawal cooldown is over.
   * @param clanId The id of the clan to withdraw from.
   * @param amount The amount of BEER to withdraw.
   */
  function clanWithdraw(uint256 clanId, uint256 amount)
    external
    ifNotOnWithdrawalCooldown(clanId, msg.sender)
  {
    address user = msg.sender;
    if(clanExists(clanId)) {
      if(!isBelowPendingWithdrawal(clanId, user, amount)) {
        revert ClanModifiers_WithdrawalAbovePending(clanId, user, amount);
      }
    } else {
      if(!isBelowStake(clanId, user, amount)) {
        revert ClanModifiers_WithdrawalAmountAboveStake(clanId, user, amount);
      } else {
        ClanStorage.state().pendingWithdrawal[clanId].set(user, _stakeOf(clanId, user));
      }
    }
    _clanWithdraw(clanId, amount);
    BEER().transfer(user, amount);
  }

//Join, Leave and Invite Proposals
  //ONLY knight supposed call the join function
  function joinClan(uint256 knightId, uint256 clanId)
    external
    ifIsKnight(knightId)
    ifOwnsItem(knightId)
    ifIsNotOnClanActivityCooldown(knightId)
    ifNotInClan(knightId)
    ifClanExists(clanId)
    ifNoJoinProposalPending(knightId)
  { _join(knightId, clanId); }

  function withdrawJoinClan(uint256 knightId, uint256 clanId)
    external
    ifIsKnight(knightId)
    ifOwnsItem(knightId)
  {
    if(_clanJoinProposal(knightId) == clanId)
    {
      _withdrawJoin(knightId, clanId);
    } else {
      revert ClanFacet_NoJoinProposal(knightId, clanId);
    }
  }

  function leaveClan(uint256 knightId, uint256 clanId)
    external
    ifIsKnight(knightId)
    ifIsInClan(knightId, clanId)
    ifOwnsItem(knightId)
    ifNotClanOwner(knightId)
  { 
    _kick(knightId, clanId);
    emit ClanKnightLeft(clanId, knightId);
  }

  function kickFromClan(uint256 knightId, uint256 clanId, uint256 callerId)
    external
    ifIsKnight(knightId)
    ifIsInClan(knightId, clanId)
    ifNotOnClanKickCooldown(callerId)
  {
    ClanRole callerRole = _roleInClan(callerId);
    ClanRole knightRole = _roleInClan(knightId);

    if(
      //Owner can kick anyone besides himself
      callerRole == ClanRole.OWNER && knightRole != ClanRole.OWNER ||
      //Admin can kick anyone below himself
      callerRole == ClanRole.ADMIN && (knightRole == ClanRole.MOD || knightRole == ClanRole.PRIVATE) ||
      //Moderator can only kick ordinary members
      callerRole == ClanRole.MOD && knightRole == ClanRole.PRIVATE)
    {
      _kick(knightId, clanId);
      //Moderators go on one hour cooldown after kick
      if (callerRole == ClanRole.MOD) {
        ClanStorage.state().clanKickCooldown[callerId] = _clanKickCoolDownConst();
      }
    } else { 
      revert ClanFacet_CantKickThisMember(knightId, clanId, callerId); 
    }
    emit ClanKnightKicked(clanId, knightId, callerId);
  }

  function approveJoinClan(uint256 knightId, uint256 clanId, uint256 callerId)
    external
    ifIsKnight(knightId)
    ifOwnsItem(callerId)
    ifIsBelowMaxMembers(clanId)
  {
    ClanRole callerRole = _roleInClan(callerId);
    if(_clanJoinProposal(knightId) != clanId) {
      revert ClanFacet_NoJoinProposal(knightId, clanId);
    }
    if(callerRole != ClanRole.OWNER && callerRole !=  ClanRole.ADMIN) {
      revert ClanFacet_InsufficientRolePriveleges(callerId);
    }
    _approveJoinClan(knightId, clanId);
    _setClanRole(clanId, knightId, ClanRole.PRIVATE);
    emit ClanJoinProposalAccepted(clanId, knightId, callerId);
  }

  function dismissJoinClan(uint256 knightId, uint256 clanId, uint256 callerId)
    external
    ifIsKnight(knightId)
    ifOwnsItem(callerId)
  {
    ClanRole callerRole = _roleInClan(callerId);
    if(_clanJoinProposal(knightId) != clanId) {
      revert ClanFacet_NoJoinProposal(knightId, clanId);
    }
    if(callerRole != ClanRole.OWNER && callerRole !=  ClanRole.ADMIN) {
      revert ClanFacet_InsufficientRolePriveleges(callerId);
    }
    _dismissJoinClan(knightId, clanId);
  }
}
