// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.0;

import { Clan, ClanRole } from "../../Meta/DataStructures.sol";

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
  ClanModifiers,
  KnightModifiers,
  ItemsModifiers
{
//Creation, Abandonment and Leader Change
  function _createClan(uint256 knightId, string calldata clanName) internal returns(uint clanId) {
    ClanStorage.state().clansInTotal++;
    clanId = _clansInTotal();
    ClanStorage.state().clan[clanId] = Clan(knightId, 0, 0, 0);
    emit ClanCreated(clanId, knightId);
    _setClanName(clanId, clanName);
    _approveJoinClan(knightId, clanId);
    _setClanRole(clanId, knightId, ClanRole.OWNER);
  }

  function _abandon(uint256 clanId) internal {
    uint256 leaderId = _clanLeader(clanId);
    KnightStorage.state().knight[leaderId].inClan = 0;
    ClanStorage.state().clan[clanId].leader = 0;
    emit ClanAbandoned(clanId, leaderId);
  }

  function _setClanRole(uint256 clanId, uint256 knightId, ClanRole newClanRole) internal {
    ClanStorage.state().roleInClan[knightId] = newClanRole;
    if (newClanRole == ClanRole.OWNER || newClanRole == ClanRole.ADMIN) {
      ClanStorage.state().clanKickCooldown[knightId] = 0;
    }
    emit ClanNewRole(clanId, knightId, newClanRole);
  }

  function _setClanName(uint256 clanId, string calldata newClanName) internal {
    ClanStorage.state().clanName[clanId] = newClanName;
    emit ClanNewName(clanId, newClanName);
  }

// Clan stakes and leveling
  function _onStake(address benefactor, uint256 clanId, uint256 amount) internal {
    ClanStorage.state().stake[benefactor][clanId] += amount;
    ClanStorage.state().clan[clanId].stake += amount;
    _leveling(clanId);

    emit ClanStakeAdded(benefactor, clanId, amount);
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

    emit ClanStakeWithdrawn(benefactor, clanId, amount);
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
      emit ClanLeveledUp(clanId, newLevel);
    } else if (currentLevel > newLevel) {
      ClanStorage.state().clan[clanId].level = newLevel;
      emit ClanLeveledDown(clanId, newLevel);
    }
  }

//Join, Leave and Invite Proposals
  function _join(uint256 knightId, uint256 clanId) internal {
    ClanStorage.state().joinProposal[knightId] = clanId;
    emit ClanKnightJoined(clanId, knightId);
  }

  function _withdrawJoin(uint256 knightId, uint256 clanId) internal {
    ClanStorage.state().joinProposal[knightId] = 0;
    emit ClanJoinProposalWithdrawn(clanId, knightId);
  }

  function _kick(uint256 knightId, uint256 clanId) internal {
    _setClanRole(clanId, knightId, ClanRole.NONE);
    ClanStorage.state().clan[clanId].totalMembers--;
    KnightStorage.state().knight[knightId].inClan = 0;
    ClanStorage.state().clanActivityCooldown[knightId] = block.timestamp + TWO_DAYS_IN_SECONDS;
    emit ClanKnightQuit(clanId, knightId);
  }

  function _approveJoinClan(uint256 knightId, uint256 clanId) internal {
    ClanStorage.state().clan[clanId].totalMembers++;
    KnightStorage.state().knight[knightId].inClan = clanId;
    ClanStorage.state().joinProposal[knightId] = 0;
    emit ClanKnightJoined(clanId, knightId);
    _setClanRole(clanId, knightId, ClanRole.PRIVATE);
  }

  function _dismissJoinClan(uint256 knightId, uint256 clanId) internal {
    ClanStorage.state().joinProposal[knightId] = 0;
    emit ClanJoinProposalDismissed(clanId, knightId);
  }
}
