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
  function createClan(uint256 knightId, string calldata clanName)
    external
    ifOwnsItem(knightId)
    ifIsKnight(knightId)
    ifNotInClan(knightId)
    ifIsNotOnClanActivityCooldown(knightId)
    ifNotClanNameTaken(clanName)
    ifIsClanNameCorrectLength(clanName)
  {
    _createClan(knightId, clanName);
  }

  function abandonClan(uint256 clanId, uint256 ownerId)
    external
    ifOwnsItem(ownerId)
    ifIsClanLeader(ownerId, clanId)
  {
    _abandonClan(clanId, ownerId);
  }

  function setClanRole(uint256 clanId, uint256 knightId, ClanRole newRole, uint256 callerId)
    external
    ifOwnsItem(_clanLeader(clanId))
    ifIsKnight(knightId)
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

  function clanWithdrawRequest(uint256 clanId, uint256 amount) 
    external
    ifClanExists(clanId)
    ifIsBelowStake(clanId, msg.sender, amount)
  {
    _clanWithdrawRequest(clanId, amount);
  }

  function clanWithdraw(uint256 clanId, uint256 amount)
    external
  //ifNotOnWithdrawalCooldown(msg.sender)
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
