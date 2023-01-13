// SPDX-License-Identifier: Unlicensed

pragma solidity ^0.8.0;

import { Clan, Proposal, ClanRole } from "../../Meta/DataStructures.sol";

import { IClan } from "../Clan/IClan.sol";
import { ClanStorage } from "../Clan/ClanStorage.sol";
import { ClanInternal } from "../Clan/ClanInternal.sol";
import { ItemsModifiers } from "../Items/ItemsModifiers.sol";
import { MetaModifiers } from "../../Meta/MetaModifiers.sol";
import { ClanGettersExternal } from "../Clan/ClanGetters.sol";

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
    ClanRole callerRole = _roleInClan(clanId, callerId);
    ClanRole knightRole = _roleInClan(clanId, knightId);
    if (newRole == ClanRole.OWNER && callerRole == ClanRole.OWNER) {
      ClanStorage.state().roleInClan[clanId][callerId] = ClanRole.ADMIN;
      ClanStorage.state().roleInClan[clanId][knightId] = ClanRole.OWNER;
      ClanStorage.state().clan[clanId].leader = knightId;
    } else if (uint8(callerRole) > uint8(knightRole) && uint8(callerRole) > uint8(newRole)) {
      ClanStorage.state().roleInClan[clanId][knightId] = newRole;
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
  { 
    if(_roleInClan(clanId, knightId) != ClanRole.OWNER) {
      _kick(knightId, clanId);
    } else {
      revert ClanFacet_CantLeaveAClanYouOwn(knightId, clanId);
    }
  }

  function kick(uint256 knightId, uint256 clanId, uint256 kickerId)
    external
    ifIsKnight(knightId)
    ifIsInClan(knightId, clanId)
  { 
    ClanRole kickerRole = _roleInClan(clanId, knightId);
    ClanRole kickedRole = _roleInClan(clanId, knightId);

    if (kickerRole == ClanRole.OWNER || 
        kickerRole == ClanRole.ADMIN && (kickedRole == ClanRole.MOD || kickedRole == ClanRole.NONE) ||
        kickerRole == ClanRole.MOD && kickedRole == ClanRole.NONE)
    {
      _kick(knightId, clanId);
    } else { 
      revert ClanFacet_CantKickThisMember(knightId, clanId, kickerId); 
    }
  }

  function approveJoinClan(uint256 knightId, uint256 clanId, uint256 approverId)
    external
    ifIsKnight(knightId)
    ifOwnsItem(approverId)
    ifIsBelowMaxMembers(clanId)
  {
    ClanRole approverRole = _roleInClan(clanId, approverId);
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
    ClanRole callerRole = _roleInClan(clanId, callerId);
    if ((callerRole == ClanRole.OWNER || callerRole ==  ClanRole.ADMIN) &&
        _clanJoinProposal(knightId) == clanId) {
      _dismissJoinClan(knightId, clanId);
    }
  }
}
