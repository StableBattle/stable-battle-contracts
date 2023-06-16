// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.0;

import { Clan, ClanRole } from "../../Meta/DataStructures.sol";

import { IClanEvents, IClanErrors } from "../Clan/IClan.sol";
import { ClanStorage } from "../Clan/ClanStorage.sol";
import { KnightStorage } from "../Knight/KnightStorage.sol";
import { KnightModifiers } from "../Knight/KnightModifiers.sol";
import { ClanModifiers } from "../Clan/ClanModifiers.sol";
import { ItemsModifiers } from "../Items/ItemsModifiers.sol";
import { EnumerableMap } from "openzeppelin-contracts/utils/structs/EnumerableMap.sol";
import { ClanSetupLib } from "../Clan/ClanSetupLib.sol";

abstract contract ClanInternal is 
  IClanEvents,
  IClanErrors,
  ClanModifiers,
  KnightModifiers,
  ItemsModifiers
{
  using EnumerableMap for EnumerableMap.AddressToUintMap;
//Creation, Abandonment and Leader Change
  function _createClan(uint256 knightId, string calldata clanName) internal returns(uint) {
    ClanStorage.layout().clansInTotal++;
    uint256 clanId = ClanStorage.layout().clansInTotal;
    ClanStorage.layout().clanLeader[clanId] = knightId;
    emit ClanCreated(clanId, knightId);
    _setClanName(clanId, clanName);
    _approveJoinClan(knightId, clanId);
    _setClanRole(clanId, knightId, ClanRole.OWNER);
    return clanId;
  }

  function _abandonClan(uint256 clanId, uint256 leaderId) internal {
    KnightStorage.layout().knightClan[leaderId] = 0;
    ClanStorage.layout().clanLeader[clanId] = 0;
    ClanStorage.layout().clanNameTaken[ClanStorage.layout().clanName[clanId]] = false;
    emit ClanAbandoned(clanId, leaderId);
  }

  function _setClanRole(uint256 clanId, uint256 knightId, ClanRole newClanRole) internal {
    ClanStorage.layout().roleInClan[knightId] = newClanRole;
    if (newClanRole == ClanRole.OWNER || newClanRole == ClanRole.ADMIN) {
      ClanStorage.layout().clanKickCooldown[knightId] = 0;
    }
    if (newClanRole == ClanRole.OWNER) {
      ClanStorage.layout().clanLeader[clanId] = knightId;
    }
    emit ClanNewRole(clanId, knightId, newClanRole);
  }

  function _setClanName(uint256 clanId, string calldata newClanName) internal {
    ClanStorage.layout().clanName[clanId] = newClanName;
    ClanStorage.layout().clanNameTaken[newClanName] = true;
    emit ClanNewName(clanId, newClanName);
  }

// Clan stakes and leveling
  function _clanStake(uint256 clanId, uint256 amount) internal {
    address user = msg.sender;
    ClanStorage.layout().stake[user][clanId] += amount;
    ClanStorage.layout().clanStake[clanId] += amount;

    uint256 newUserStake = 
      ClanStorage.layout().withdrawalCooldown[clanId][user] <= block.timestamp ?
        ClanStorage.layout().stake[user][clanId] - ClanStorage.pendingWithdrawal(clanId, user) :
        ClanStorage.layout().stake[user][clanId];
    emit ClanStakeAdded(
      user,
      clanId,
      amount,
      ClanStorage.clanStake(clanId),
      newUserStake
    );
  }

  function _clanWithdrawRequest(uint256 clanId, uint256 amount) internal {
    address user = msg.sender;
    ClanStorage.layout().pendingWithdrawal[clanId].set(user, amount);
    ClanStorage.layout().withdrawalCooldown[clanId][user] = 
      block.timestamp + ClanSetupLib.clanStakeWithdrawCooldownConst;
    emit ClanStakeWithdrawRequest(
      user,
      clanId,
      amount,
      block.timestamp + ClanSetupLib.clanStakeWithdrawCooldownConst
    );
  }

  function _clanWithdraw(uint256 clanId, uint256 amount) internal {
    address user = msg.sender;
    uint256 userWithdrawAllowance = ClanStorage.pendingWithdrawal(clanId, user);
    if (userWithdrawAllowance == amount) {
      ClanStorage.layout().pendingWithdrawal[clanId].remove(user);
    } else {
      ClanStorage.layout().pendingWithdrawal[clanId].set(user, userWithdrawAllowance - amount);
    }
    ClanStorage.layout().stake[user][clanId] -= amount;
    ClanStorage.layout().clanStake[clanId] -= amount;

    uint256 newUserStake = 
      ClanStorage.layout().withdrawalCooldown[clanId][user] <= block.timestamp ?
        ClanStorage.layout().stake[user][clanId] - ClanStorage.pendingWithdrawal(clanId, user) :
        ClanStorage.layout().stake[user][clanId];
    emit ClanStakeWithdrawn(
      user,
      clanId,
      amount,
      ClanStorage.clanStake(clanId),
      newUserStake
    );
  }

//Join, Leave and Invite Proposals
  function _join(uint256 knightId, uint256 clanId) internal {
    ClanStorage.layout().joinProposal[knightId] = clanId;
    emit ClanJoinProposalSent(clanId, knightId);
  }

  function _withdrawJoin(uint256 knightId, uint256 clanId) internal {
    ClanStorage.layout().joinProposal[knightId] = 0;
    emit ClanJoinProposalWithdrawn(clanId, knightId);
  }

  function _kick(uint256 knightId, uint256 clanId) internal {
    _setClanRole(clanId, knightId, ClanRole.NONE);
    ClanStorage.layout().clanTotalMembers[clanId]--;
    KnightStorage.layout().knightClan[knightId] = 0;
    if(ClanStorage.layout().clanLeader[clanId] != 0) {
      ClanStorage.layout().clanActivityCooldown[knightId] =
        block.timestamp + ClanSetupLib.clanActivityCooldownConst;
    }
    emit ClanKnightQuit(clanId, knightId);
  }

  function _approveJoinClan(uint256 knightId, uint256 clanId) internal {
    ClanStorage.layout().clanTotalMembers[clanId]++;
    KnightStorage.layout().knightClan[knightId] = clanId;
    ClanStorage.layout().joinProposal[knightId] = 0;
    emit ClanKnightJoined(clanId, knightId);
  }

  function _dismissJoinClan(uint256 knightId, uint256 clanId) internal {
    ClanStorage.layout().joinProposal[knightId] = 0;
    emit ClanJoinProposalDismissed(clanId, knightId);
  }
}
