// SPDX-License-Identifier: Unlicensed

pragma solidity ^0.8.0;

import { Clan, ClanRole } from "../../Meta/DataStructures.sol";

import { IClan } from "../Clan/IClan.sol";
import { ClanStorage } from "../Clan/ClanStorage.sol";
import { ClanInternal } from "../Clan/ClanInternal.sol";
import { ItemsModifiers } from "../Items/ItemsModifiers.sol";
import { MetaModifiers } from "../../Meta/MetaModifiers.sol";
import { ClanGettersExternal } from "../Clan/ClanGetters.sol";

uint constant ONE_HOUR_IN_SECONDS = 60 * 60;

contract ClanFacet is
  IClan,
  ItemsModifiers,
  MetaModifiers,
  ClanGettersExternal,
  ClanInternal
{

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
      ClanStorage.state().clanLeader[clanId] = knightId;
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
  function onStake(address benefactor, uint256 clanId, uint256 amount)
    external
  //onlySBT
    ifClanExists(clanId)
  { _onStake(benefactor, clanId, amount); }

  function onWithdraw(address benefactor, uint256 clanId, uint256 amount)
    external
  //onlySBT
  { _onWithdraw(benefactor, clanId, amount); }

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
        ClanStorage.state().clanKickCooldown[callerId] = ONE_HOUR_IN_SECONDS;
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
