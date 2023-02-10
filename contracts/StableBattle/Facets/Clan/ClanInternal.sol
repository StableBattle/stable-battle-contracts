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
import { EnumerableMap } from "@openzeppelin/contracts/utils/structs/EnumerableMap.sol";

uint constant TWO_DAYS_IN_SECONDS = 2 * 24 * 60 * 60;
uint256 constant TWO_WEEKS_IN_SECONDS = 60 * 60 * 24 * 14;

abstract contract ClanInternal is 
  IClanEvents,
  IClanErrors,
  ClanGetters,
  ClanModifiers,
  KnightModifiers,
  ItemsModifiers
{
  using EnumerableMap for EnumerableMap.AddressToUintMap;
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

    uint256 newUserStake = 
      _withdrawalCooldown(clanId, user) <= block.timestamp ?
        _stakeOf(clanId, user) - _pendingWithdrawal(clanId, user) :
        _stakeOf(clanId, user);
    emit ClanStakeAdded(
      user,
      clanId,
      amount,
      _clanStake(clanId),
      newUserStake
    );
  }

  function _clanWithdrawRequest(uint256 clanId, uint256 amount) internal {
    address user = msg.sender;
    ClanStorage.state().pendingWithdrawal[clanId].set(user, amount);
    ClanStorage.state().withdrawalCooldown[clanId][user] = block.timestamp + TWO_WEEKS_IN_SECONDS;
    emit ClanStakeWithdrawRequest(user, clanId, amount, block.timestamp + TWO_WEEKS_IN_SECONDS);
  }

  function _clanWithdraw(uint256 clanId, uint256 amount) internal {
    address user = msg.sender;
    uint256 userWithdrawAllowance = _pendingWithdrawal(clanId, user);
    if (userWithdrawAllowance == amount) {
      ClanStorage.state().pendingWithdrawal[clanId].remove(user);
    } else {
      ClanStorage.state().pendingWithdrawal[clanId].set(user, userWithdrawAllowance - amount);
    }
    ClanStorage.state().stake[user][clanId] -= amount;
    ClanStorage.state().clanStake[clanId] -= amount;

    uint256 newUserStake = 
      _withdrawalCooldown(clanId, user) <= block.timestamp ?
        _stakeOf(clanId, user) - _pendingWithdrawal(clanId, user) :
        _stakeOf(clanId, user);
    emit ClanStakeWithdrawn(
      user,
      clanId,
      amount,
      _clanStake(clanId),
      newUserStake
    );
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
