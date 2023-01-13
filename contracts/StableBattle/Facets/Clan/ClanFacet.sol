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
  function createClan(uint256 knightId)
    external
    ifOwnsItem(knightId)
    ifIsKnight(knightId)
    ifNotInClan(knightId)
    ifIsNotOnClanActivityCooldown(knightId)
    returns(uint)
  { return _createClan(knightId); }

  function setClanRole(uint256 clanId, uint256 knightId, ClanRole newRole, uint256 callerId)
    external
    ifOwnsItem(_clanLeader(clanId))
    ifIsKnight(knightId)
    ifIsInClan(knightId, clanId)
  {
    ClanRole callerRole = _roleInClan(callerId);
    ClanRole knightRole = _roleInClan(knightId);
    if (newRole == ClanRole.OWNER && callerRole == ClanRole.OWNER) {
      ClanStorage.state().roleInClan[callerId] = ClanRole.ADMIN;
      ClanStorage.state().roleInClan[knightId] = ClanRole.OWNER;
      ClanStorage.state().clan[clanId].leader = knightId;
    } else if (uint8(callerRole) > uint8(knightRole) && uint8(callerRole) > uint8(newRole)) {
      ClanStorage.state().roleInClan[knightId] = newRole;
    } else {
      revert ClanFacet_CantAssignNewRoleToThisCharacter(clanId, knightId, newRole, callerId);
    }
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
  function join(uint256 knightId, uint256 clanId)
    external
    ifIsKnight(knightId)
    ifOwnsItem(knightId)
    ifIsNotOnClanActivityCooldown(knightId)
    ifNotInClan(knightId)
    ifClanExists(clanId)
    ifNoJoinProposalPending(knightId)
  { _join(knightId, clanId); }

  function withdrawJoin(uint256 knightId, uint256 clanId)
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

  function leave(uint256 knightId, uint256 clanId)
    external
    ifIsKnight(knightId)
    ifIsInClan(knightId, clanId)
    ifOwnsItem(knightId)
    ifNotClanOwner(knightId)
  { 
    _kick(knightId, clanId);
  }

  function kick(uint256 knightId, uint256 clanId, uint256 callerId)
    external
    ifIsKnight(knightId)
    ifIsInClan(knightId, clanId)
    ifNotOnClanKickCooldown(callerId)
  {
    ClanRole callerRole = _roleInClan(knightId);
    ClanRole knightRole = _roleInClan(knightId);

    if(
      //Owner can kick anyone besides himself
      callerRole == ClanRole.OWNER && knightRole != ClanRole.OWNER ||
      //Admin can kick anyone below himself
      callerRole == ClanRole.ADMIN && (knightRole == ClanRole.MOD || knightRole == ClanRole.NONE) ||
      //Moderator can only kick ordinary members
      callerRole == ClanRole.MOD && knightRole == ClanRole.NONE)
    {
      _kick(knightId, clanId);
      //Moderators go on one hour cooldown after kick
      if (callerRole == ClanRole.MOD) {
        ClanStorage.state().clanKickCooldown[callerId] = ONE_HOUR_IN_SECONDS;
      }
    } else { 
      revert ClanFacet_CantKickThisMember(knightId, clanId, callerId); 
    }
  }

  function approveJoinClan(uint256 knightId, uint256 clanId, uint256 callerId)
    external
    ifIsKnight(knightId)
    ifOwnsItem(callerId)
    ifIsBelowMaxMembers(clanId)
  {
    ClanRole approverRole = _roleInClan(callerId);
    if ((approverRole == ClanRole.OWNER || approverRole ==  ClanRole.ADMIN) &&
        _clanJoinProposal(knightId) == clanId) {
      _approveJoinClan(knightId, clanId);
    }
  }

  function dismissJoinClan(uint256 knightId, uint256 clanId, uint256 callerId)
    external
    ifIsKnight(knightId)
    ifOwnsItem(callerId)
  {
    ClanRole callerRole = _roleInClan(callerId);
    if ((callerRole == ClanRole.OWNER || callerRole ==  ClanRole.ADMIN) &&
        _clanJoinProposal(knightId) == clanId) {
      _dismissJoinClan(knightId, clanId);
    }
  }
}
