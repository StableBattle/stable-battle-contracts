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
    ClanStorage.state().clanLeader[clanId] = knightId;
    emit ClanCreated(clanId, knightId);
    _setClanName(clanId, clanName);
    _setClanLevel(clanId, 1);
    _approveJoinClan(knightId, clanId);
    _setClanRole(clanId, knightId, ClanRole.OWNER);
  }

  function _abandonClan(uint256 clanId, uint256 leaderId) internal {
    KnightStorage.state().knight[leaderId].inClan = 0;
    ClanStorage.state().clanLeader[clanId] = 0;
    emit ClanAbandoned(clanId, leaderId);
  }

  function _setClanRole(uint256 clanId, uint256 knightId, ClanRole newClanRole) internal {
    ClanStorage.state().roleInClan[knightId] = newClanRole;
    if (newClanRole == ClanRole.OWNER || newClanRole == ClanRole.ADMIN) {
      ClanStorage.state().clanKickCooldown[knightId] = 0;
    }
    if (newClanRole == ClanRole.OWNER) {
      ClanStorage.state().clanLeader[clanId] = knightId;
    }
    emit ClanNewRole(clanId, knightId, newClanRole);
  }

  function _setClanName(uint256 clanId, string calldata newClanName) internal {
    ClanStorage.state().clanName[clanId] = newClanName;
    emit ClanNewName(clanId, newClanName);
  }

// Clan stakes and leveling
  function _clanStake(uint256 clanId, uint256 amount) internal {
    address user = msg.sender;
    ClanStorage.state().stake[user][clanId] += amount;
    ClanStorage.state().clanStake[clanId] += amount;
    _leveling(clanId);

    emit ClanStakeAdded(user, clanId, amount, _clanStake(clanId), _stakeOf(user, clanId));
  }

  function _clanWithdraw(uint256 clanId, uint256 amount) internal {
    address user = msg.sender;
    ClanStorage.state().allowedWithdrawal[user] -= amount;
    ClanStorage.state().stake[user][clanId] -= amount;
    ClanStorage.state().clanStake[clanId] -= amount;
    _leveling(clanId);

    emit ClanStakeWithdrawn(user, clanId, amount, _clanStake(clanId), _stakeOf(user, clanId));
  }

  //Calculate clan level based on stake
  function _leveling(uint256 clanId) private {
    uint256 currentLevel = _clanLevel(clanId);
    uint256 stake = _clanStake(clanId);
    uint256[] memory thresholds = ClanStorage.state().levelThresholds;
    uint256 maxLevel = thresholds.length;
    uint256 newLevel = 1;
    while (stake >= thresholds[newLevel] && newLevel < maxLevel) {
      newLevel++;
    }
    if (currentLevel != newLevel) {
      _setClanLevel(clanId, newLevel);
    }
  }

  function _setClanLevel(uint256 clanId, uint256 newLevel) internal {
    ClanStorage.state().clanLevel[clanId] = newLevel;
    emit ClanNewLevel(clanId, newLevel);
  }

//Join, Leave and Invite Proposals
  function _join(uint256 knightId, uint256 clanId) internal {
    ClanStorage.state().joinProposal[knightId] = clanId;
    emit ClanJoinProposalSent(clanId, knightId);
  }

  function _withdrawJoin(uint256 knightId, uint256 clanId) internal {
    ClanStorage.state().joinProposal[knightId] = 0;
    emit ClanJoinProposalWithdrawn(clanId, knightId);
  }

  function _kick(uint256 knightId, uint256 clanId) internal {
    _setClanRole(clanId, knightId, ClanRole.NONE);
    ClanStorage.state().clanTotalMembers[clanId]--;
    KnightStorage.state().knight[knightId].inClan = 0;
    if(_clanLeader(clanId) != 0) {
      ClanStorage.state().clanActivityCooldown[knightId] = block.timestamp + TWO_DAYS_IN_SECONDS;
    }
    emit ClanKnightQuit(clanId, knightId);
  }

  function _approveJoinClan(uint256 knightId, uint256 clanId) internal {
    ClanStorage.state().clanTotalMembers[clanId]++;
    KnightStorage.state().knight[knightId].inClan = clanId;
    ClanStorage.state().joinProposal[knightId] = 0;
    emit ClanKnightJoined(clanId, knightId);
  }

  function _dismissJoinClan(uint256 knightId, uint256 clanId) internal {
    ClanStorage.state().joinProposal[knightId] = 0;
    emit ClanJoinProposalDismissed(clanId, knightId);
  }
}
