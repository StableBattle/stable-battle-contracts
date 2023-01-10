// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.0;

import { Clan, Proposal } from "../../Meta/DataStructures.sol";

import { IClanEvents, IClanErrors } from "../Clan/IClan.sol";
import { ClanStorage } from "../Clan/ClanStorage.sol";
import { KnightStorage } from "../Knight/KnightStorage.sol";
import { KnightModifiers } from "../Knight/KnightModifiers.sol";
import { ClanGetters } from "../Clan/ClanGetters.sol";
import { ClanModifiers } from "../Clan/ClanModifiers.sol";
import { ItemsModifiers } from "../Items/ItemsModifiers.sol";

abstract contract ClanInternal is 
  IClanEvents,
  IClanErrors,
  ClanGetters, 
  KnightModifiers, 
  ClanModifiers,
  ItemsModifiers 
{
//Creation, Abandonment and Leader Change
  function _create(uint256 knightId)
    internal
    ifIsKnight(knightId)
    ifNotInClan(knightId)
    returns(uint clanId)
  {
    clanId = _clansInTotal() + 1;
    ClanStorage.state().clan[clanId] = Clan(knightId, 0, 1, 0);
    KnightStorage.state().knight[knightId].inClan = clanId;
    ClanStorage.state().clansInTotal++;
    emit ClanCreated(clanId, knightId);
  }

  function _abandon(uint256 clanId) 
    internal
  {
    uint256 leaderId = _clanLeader(clanId);
    KnightStorage.state().knight[leaderId].inClan = 0;
    ClanStorage.state().clan[clanId].leader = 0;
    emit ClanAbandoned(clanId, leaderId);
  }

  function _changeLeader(uint256 clanId, uint256 knightId)
    internal
    ifIsKnight(knightId)
    ifIsInClan(knightId, clanId)
    ifIsNotClanLeader(knightId, clanId)
  {
    ClanStorage.state().clan[clanId].leader = knightId;
  }

// Clan stakes and leveling
  function _onStake(address benefactor, uint256 clanId, uint256 amount)
    internal
    ifClanExists(clanId)
  {
    ClanStorage.state().stake[benefactor][clanId] += amount;
    ClanStorage.state().clan[clanId].stake += amount;
    _leveling(clanId);

    emit StakeAdded(benefactor, clanId, amount);
  }

  function _onWithdraw(address benefactor, uint256 clanId, uint256 amount)
    internal
    ifClanExists(clanId)
  {
    uint256 stake = _stakeOf(benefactor, clanId);
    if (stake < amount) {
      revert ClanFacet_InsufficientStake({
        stakeAvalible: stake,
        withdrawAmount: amount
      });
    }
    
    ClanStorage.state().stake[benefactor][clanId] -= amount;
    ClanStorage.state().clan[clanId].stake -= amount;
    _leveling(clanId);

    emit StakeWithdrawn(benefactor, clanId, amount);
  }

  //Calculate clan level based on stake
  function _leveling(uint256 clanId) private {
    uint newLevel = 0;
    while (_clanStake(clanId) > _clanLevelThreshold(newLevel) &&
           newLevel < _clanMaxLevel()) {
      newLevel++;
    }
    if (_clanLevel(clanId) < newLevel) {
      ClanStorage.state().clan[clanId].level = newLevel;
      emit ClanLeveledUp (clanId, newLevel);
    } else if (_clanLevel(clanId) > newLevel) {
      ClanStorage.state().clan[clanId].level = newLevel;
      emit ClanLeveledDown (clanId, newLevel);
    }
  }

//Join, Leave and Invite Proposals
  //ONLY knight supposed call the join function
  function _join(uint256 knightId, uint256 clanId)
    internal
    ifIsKnight(knightId)
    ifClanExists(clanId)
  {
    uint256 knightClan = _knightClan(knightId);
    if (clanExists(knightClan)) {
      revert ClanFacet_CantJoinAlreadyInClan(knightId, knightClan);
    }

    if (_proposal(knightId, clanId) == Proposal.INVITE) {
      //join clan immediately if invited
      ClanStorage.state().clan[clanId].totalMembers++;
      KnightStorage.state().knight[knightId].inClan = clanId;
      ClanStorage.state().proposal[knightId][clanId] = Proposal.NONE;
      emit KnightJoinedClan(clanId, knightId);
    } else {
      //create join proposal
      ClanStorage.state().proposal[knightId][clanId] = Proposal.JOIN;
      emit KnightAskedToJoin(clanId, knightId);
    }
  }

  //BOTH knights and leaders supposed call the leave function
  function _leave(uint256 knightId)
    internal
    ifIsKnight(knightId)
    ifIsInAnyClan(knightId)
  { 
    uint256 clanId = _knightClan(knightId);
    if ((clanExists(clanId) && _proposal(knightId, clanId) != Proposal.LEAVE)) {
      //create leave proposal if clan exist & such proposal doesn't
      ClanStorage.state().proposal[knightId][clanId] = Proposal.LEAVE;
      emit KnightAskedToLeave(clanId, knightId);
    } else if(ownsItem(_clanLeader(clanId)) || !clanExists(clanId)) {
      //leave abandoned clan or allow knight to leave if clan leader
      _kick(knightId);
    } else {
      revert ClanFacet_NoProposalOrNotClanLeader(knightId, clanId);
    }
  }

  function _kick(uint256 knightId)
    internal
    ifIsKnight(knightId)
    ifIsInAnyClan(knightId)
  {
    uint256 clanId = _knightClan(knightId);
    ClanStorage.state().clan[clanId].totalMembers--;
    KnightStorage.state().knight[knightId].inClan = 0;
    ClanStorage.state().proposal[knightId][clanId] = Proposal.NONE;
    emit KnightLeftClan(clanId, knightId);
  }

  //ONLY leaders supposed call the invite function
  function _invite(uint256 knightId, uint256 clanId)
    internal
    ifIsKnight(knightId)
    ifNotInClan(knightId)
  {
    if (_proposal(knightId, clanId) == Proposal.JOIN && notInClan(knightId)) {
      //welcome the knight to join if it already offered it
      ClanStorage.state().clan[clanId].totalMembers++;
      KnightStorage.state().knight[knightId].inClan = clanId;
      ClanStorage.state().proposal[knightId][clanId] = Proposal.NONE;
      emit KnightJoinedClan(clanId, knightId);
    } else {
      //create invite proposal for the knight
      ClanStorage.state().proposal[knightId][clanId] = Proposal.INVITE;
      emit KnightInvitedToClan(clanId, knightId);
    }
  }
}
