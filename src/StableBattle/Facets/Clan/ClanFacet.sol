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
import { EnumerableMap } from "openzeppelin-contracts/utils/structs/EnumerableMap.sol";

/**
 * @title A facet of the StableBattle game contract that manages clan functionality.
 * @author Pavel Ivanov <zeuamsa@gmail.com>
 * @notice The purpose of this contract is to implement checks for external functions that access internal code.
 * @dev To see internal wokings of each function look into ClanInternal.sol
 */
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
  //ifIsNotOnClanActivityCooldown(knightId)
    ifNotClanNameTaken(clanName)
    ifIsClanNameCorrectLength(clanName)
    returns (uint256)
  {
    return _createClan(knightId, clanName);
  }

  // This function allows the owner of a clan to abandon the clan.
  /**
   * @dev Abandons a clan. Only clan owner can call this this.
   * @param clanId The id of the clan to be abandoned.
   * @param ownerId The id of the clan owner.
   */
  function abandonClan(uint256 clanId, uint256 ownerId)
    external
    ifOwnsItem(ownerId)
    ifIsClanLeader(ownerId, clanId)
  {
    _abandonClan(clanId, ownerId);
  }

  /**
  * @notice Allows the owner/admin of a clan to assign a new role to a knight in the clan
  * @param clanId The id of the clan the knight belongs to
  * @param knightId The id of the knight to be assigned a new role
  * @param newRole The role to be assigned
  * @param callerId The id of the owned knight with sufficiently high role
  */
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

  /**
   * @notice Assigns a new name to a clan.
   * @param clanId The id of the clan to update the name of.
   * @param newClanName The new clan name.
   */
  function setClanName(uint256 clanId, string calldata newClanName)
    external
    ifOwnsItem(_clanLeader(clanId))
    ifNotClanNameTaken(newClanName)
    ifIsClanNameCorrectLength(newClanName)
  {
    _setClanName(clanId, newClanName);
  }

// Clan stakes and leveling
  /**
   * @notice Stake BEER into a clan
   * @param clanId Id of the clan to stake into
   * @param amount Amount of BEER to stake
   */
  function clanStake(uint256 clanId, uint256 amount)
    external
    ifClanExists(clanId)
  { 
    _clanStake(clanId, amount); 
    BEER.transferFrom(msg.sender, address(this), amount);
  }

  /**
  * @notice Allows a user to request a withdrawal of their clan stake
  * @param clanId Id of the clan to request a withdrawal from
  * @param amount Amount to withdraw
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
   * @param clanId Id of the clan to withdraw from.
   * @param amount Amount of BEER to withdraw.
   */
  function clanWithdraw(uint256 clanId, uint256 amount)
    external
  //ifNotOnWithdrawalCooldown(clanId, msg.sender)
  {
    address user = msg.sender;
    if(clanExists(clanId)) {
      if(!isBelowPendingWithdrawal(clanId, user, amount)) {
      //revert ClanModifiers_WithdrawalAbovePending(clanId, user, amount);
        revert("Withdrawal amount above pending withdrawal");
      }
    } else {
      if(!isBelowStake(clanId, user, amount)) {
      //revert ClanModifiers_WithdrawalAmountAboveStake(clanId, user, amount);
        revert("Withdrawal amount above stake");
      } else {
        ClanStorage.layout().pendingWithdrawal[clanId].set(user, _stakeOf(clanId, user));
      }
    }
    _clanWithdraw(clanId, amount);
    BEER.transfer(user, amount);
  }

//Join, Leave and Invite Proposals
  /**
  * @notice Join a clan
  * @dev Only a clanless knight supposed to call this function
  * @param knightId The id of the knight
  * @param clanId The id of the clan
  */
  function joinClan(uint256 knightId, uint256 clanId)
    external
    ifIsKnight(knightId)
    ifOwnsItem(knightId)
  //ifIsNotOnClanActivityCooldown(knightId)
    ifNotInClan(knightId)
    ifClanExists(clanId)
  //ifNoJoinProposalPending(knightId)
  {
    if(clanId != 0) {
      if(clanExists(clanId)) {
        _join(knightId, clanId);
      } else {
      //revert ClanFacet_ClanDoesNotExist(clanId);
        revert("Clan does not exist");
      }
    } else {
      if(_clanJoinProposal(knightId) != 0)
      {
        _withdrawJoin(knightId, _clanJoinProposal(knightId));
      } else {
      //revert ClanFacet_NoJoinProposal(knightId, clanId);
        revert("No join proposal");
      }
    }
  }

  /**
   * @dev Withdraw a clan join proposal
   * @param knightId Id of the knight who made the proposal
   * @param clanId Id of the clan to withdraw a proposal from
   */
  function withdrawJoinClan(uint256 knightId, uint256 clanId)
    external
    ifIsKnight(knightId)
    ifOwnsItem(knightId)
  {
    if(_clanJoinProposal(knightId) == clanId)
    {
      _withdrawJoin(knightId, clanId);
    } else {
    //revert ClanFacet_NoJoinProposal(knightId, clanId);
      revert("No join proposal");
    }
  }

  /**
  * @notice Allows a knight to leave a clan on their own
  * @dev Called by a knight who that wants to leave
  * @param knightId Id of the knight who wants to leave
  * @param clanId Id of the clan to leave from
  */
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

  /**
  * @notice Kicks a knight from a clan
  * @dev Only clan owner, admin or moderator can kick a knight
  * @dev Moderator recieves a 2 day cooldown on kicking
  * @param knightId Id of the knight to be kicked
  * @param clanId Id of the clan to kick the knight from
  * @param callerId Id of the owned knight with the permission to kick who is calling the function
  */
  function kickFromClan(uint256 knightId, uint256 clanId, uint256 callerId)
    external
    ifIsKnight(knightId)
    ifIsInClan(knightId, clanId)
    ifIsInClan(callerId, clanId)
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
        ClanStorage.layout().clanKickCooldown[callerId] = _clanKickCoolDownConst();
      }
    } else { 
    //revert ClanFacet_CantKickThisMember(knightId, clanId, callerId);
      revert("Can't kick this member");
    }
    emit ClanKnightKicked(clanId, knightId, callerId);
  }

  /**
  * @notice Approve the join clan proposal for a knight
  * @param knightId Id of the knight who made the proposal
  * @param clanId Id of the clan knight wants to join
  * @param callerId Id of the owned knight with the permission to approve the proposal
  */
  function approveJoinClan(uint256 knightId, uint256 clanId, uint256 callerId)
    external
    ifIsKnight(knightId)
    ifOwnsItem(callerId)
    ifIsInClan(callerId, clanId)
  //ifIsBelowMaxMembers(clanId)
  {
    ClanRole callerRole = _roleInClan(callerId);
    if(_clanJoinProposal(knightId) != clanId) {
    //revert ClanFacet_NoJoinProposal(knightId, clanId);
      revert("No join proposal");
    }
    if(callerRole != ClanRole.OWNER && callerRole !=  ClanRole.ADMIN) {
    //revert ClanFacet_InsufficientRolePriveleges(callerId);
      revert("Insufficient role priveleges");
    }
    _approveJoinClan(knightId, clanId);
    _setClanRole(clanId, knightId, ClanRole.PRIVATE);
    emit ClanJoinProposalAccepted(clanId, knightId, callerId);
  }

  /**
   * @notice Dismisses a pending join clan request.
   * @param knightId Id of the knight who made the proposal.
   * @param clanId Id of the clan knight wants to join.
   * @param callerId Id of the owned knight with the permission to dismiss the proposal.
   */
  function dismissJoinClan(uint256 knightId, uint256 clanId, uint256 callerId)
    external
    ifIsKnight(knightId)
    ifOwnsItem(callerId)
  {
    ClanRole callerRole = _roleInClan(callerId);
    if(_clanJoinProposal(knightId) != clanId) {
    //revert ClanFacet_NoJoinProposal(knightId, clanId);
      revert("No join proposal");
    }
    if(callerRole != ClanRole.OWNER && callerRole !=  ClanRole.ADMIN) {
    //revert ClanFacet_InsufficientRolePriveleges(callerId);
      revert("Insufficient role priveleges");
    }
    _dismissJoinClan(knightId, clanId);
  }
}
