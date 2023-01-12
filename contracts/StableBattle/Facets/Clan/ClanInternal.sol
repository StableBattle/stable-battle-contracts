// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.0;

import { Clan, Proposal, ClanRole } from "../../Meta/DataStructures.sol";

import { IClanEvents, IClanErrors } from "../Clan/IClan.sol";
import { ClanStorage } from "../Clan/ClanStorage.sol";
import { KnightStorage } from "../Knight/KnightStorage.sol";
import { KnightModifiers } from "../Knight/KnightModifiers.sol";
import { ClanGetters } from "../Clan/ClanGetters.sol";
import { ClanModifiers } from "../Clan/ClanModifiers.sol";
import { ItemsModifiers } from "../Items/ItemsModifiers.sol";

uint constant TWO_DAYS_IN_SECONDS = 2 * 24 * 60 * 60;

abstract contract ClanInternal is 
  IClanEvents,
  IClanErrors,
  ClanGetters, 
  KnightModifiers,
  ClanModifiers,
  ItemsModifiers 
{
//Creation, Abandonment and Leader Change
  function _createClan(uint256 knightId) internal returns(uint clanId) {
    clanId = _clansInTotal() + 1;
    ClanStorage.state().clan[clanId] = Clan(knightId, 0, 1, 0);
    KnightStorage.state().knight[knightId].inClan = clanId;
    ClanStorage.state().clansInTotal++;
    emit ClanCreated(clanId, knightId);
  }

  function _abandon(uint256 clanId) internal {
    uint256 leaderId = _clanLeader(clanId);
    KnightStorage.state().knight[leaderId].inClan = 0;
    ClanStorage.state().clan[clanId].leader = 0;
    emit ClanAbandoned(clanId, leaderId);
  }

  function _setClanRole(uint256 clanId, uint256 knightId, ClanRole newClanRole) internal {
    ClanStorage.state().roleInClan[clanId][knightId] = newClanRole;
    emit NewClanRole(clanId, knightId, newClanRole);
  }

// Clan stakes and leveling
  function _onStake(address benefactor, uint256 clanId, uint256 amount) internal {
    ClanStorage.state().stake[benefactor][clanId] += amount;
    ClanStorage.state().clan[clanId].stake += amount;
    _leveling(clanId);

    emit StakeAdded(benefactor, clanId, amount);
  }

  function _onWithdraw(address benefactor, uint256 clanId, uint256 amount) internal {
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
    uint currentLevel = _clanLevel(clanId);
    uint256 stake = _clanStake(clanId);
    uint[] memory thresholds = ClanStorage.state().levelThresholds;
    uint maxLevel = thresholds.length;
    uint newLevel = 0;
    while (stake > thresholds[newLevel] && newLevel < maxLevel) {
      newLevel++;
    }
    if (currentLevel < newLevel) {
      ClanStorage.state().clan[clanId].level = newLevel;
      emit ClanLeveledUp (clanId, newLevel);
    } else if (currentLevel > newLevel) {
      ClanStorage.state().clan[clanId].level = newLevel;
      emit ClanLeveledDown (clanId, newLevel);
    }
  }

//Join, Leave and Invite Proposals
  function _join(uint256 knightId, uint256 clanId) internal {
    //leave old clan before joining a new one
    uint256 knightClan = _knightClan(knightId);
    if(knightClan != 0) { _kick(knightId, knightClan); }

    //create join proposal
    ClanStorage.state().proposal[knightId][clanId] = Proposal.JOIN;
    ClanStorage.state().joinProposalPending[knightId] = true;
    emit KnightAskedToJoin(clanId, knightId);
  }

  function _withdrawJoin(uint256 knightId, uint256 clanId) internal {
    ClanStorage.state().proposal[knightId][clanId] = Proposal.NONE;
    ClanStorage.state().joinProposalPending[knightId] = false;
    emit KnightNoLongerWantsToJoin(clanId, knightId);
  }

  function _kick(uint256 knightId, uint256 clanId) internal {
    ClanStorage.state().clan[clanId].totalMembers--;
    KnightStorage.state().knight[knightId].inClan = 0;
    ClanStorage.state().proposal[knightId][clanId] = Proposal.NONE;
    ClanStorage.state().clanActivityCooldown[knightId] = block.timestamp + TWO_DAYS_IN_SECONDS;
    emit KnightLeftClan(clanId, knightId);
  }

  function _approveJoinClan(uint256 knightId, uint256 clanId) internal {
    if (_proposal(knightId, clanId) == Proposal.JOIN) {
      //welcome the knight to join if it already offered it
      ClanStorage.state().clan[clanId].totalMembers++;
      KnightStorage.state().knight[knightId].inClan = clanId;
      ClanStorage.state().proposal[knightId][clanId] = Proposal.NONE;
      ClanStorage.state().joinProposalPending[knightId] = false;
      emit KnightJoinedClan(clanId, knightId);
    }
  }

  function _dismissJoinClan(uint256 knightId, uint256 clanId) internal {
    if (_proposal(knightId, clanId) == Proposal.JOIN) {
      //dismiss the knight to join if it already offered it
      ClanStorage.state().proposal[knightId][clanId] = Proposal.NONE;
      ClanStorage.state().joinProposalPending[knightId] = false;
      emit KnightJoinDismissed(clanId, knightId);
    }
  }

  function _invite(uint256 knightId, uint256 clanId) internal {
    if (_proposal(knightId, clanId) == Proposal.NONE) {
      //create invite proposal for the knight
      ClanStorage.state().proposal[knightId][clanId] = Proposal.INVITE;
      emit KnightInvitedToClan(clanId, knightId);
    }
  }
}
