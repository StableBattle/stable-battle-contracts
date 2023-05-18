// SPDX-License-Identifier: Unlicensed

pragma solidity ^0.8.0;

import { Clan, ClanRole } from "../../Meta/DataStructures.sol";
import { ClanStorage } from "../Clan/ClanStorage.sol";
import { IClanErrors } from "../Clan/IClan.sol";
import { ClanGetters } from "../Clan/ClanGetters.sol";

abstract contract ClanModifiers is IClanErrors, ClanGetters {
  function clanExists(uint256 clanId) internal view returns(bool) {
    return ClanStorage.layout().clanLeader[clanId] != 0;
  }

  modifier ifClanExists(uint256 clanId) {
    if(!clanExists(clanId)) {
    //revert ClanModifiers_ClanDoesntExist(clanId);
      revert("Clan Modifiers: Clan Doesn't Exist");
    }
    _;
  }

  function isClanLeader(uint256 knightId, uint256 clanId) internal view returns(bool) {
    return ClanStorage.layout().clanLeader[clanId] == knightId;
  }

  modifier ifIsClanLeader(uint256 knightId, uint clanId) {
    if(!isClanLeader(knightId, clanId)) {
    //revert ClanModifiers_KnightIsNotClanLeader(knightId, clanId);
      revert("Clan Modifiers: Knight Is Not Clan Leader");
    }
    _;
  }

  function isNotClanLeader(uint256 knightId, uint256 clanId) internal view returns(bool) {
    return ClanStorage.layout().clanLeader[clanId] != knightId;
  }

  modifier ifIsNotClanLeader(uint256 knightId, uint clanId) {
    if(!isNotClanLeader(knightId, clanId)) {
    //revert ClanModifiers_KnightIsClanLeader(knightId, clanId);
      revert("Clan Modifiers: Knight Is Clan Leader");
    }
    _;
  }

  function isOnClanActivityCooldown(uint256 knightId) internal view returns(bool) {
    return _clanActivityCooldown(knightId) > block.timestamp;
  }

  modifier ifIsNotOnClanActivityCooldown(uint256 knightId) {
    if (isOnClanActivityCooldown(knightId)) {
    //revert ClanModifiers_KnightOnClanActivityCooldown(knightId);
      revert("Clan Modifiers: Knight On Clan Activity Cooldown");
    }
    _;
  }

  function isJoinProposalPending(uint256 knightId) internal view returns(bool) {
    return _clanJoinProposal(knightId) != 0;
  }

  modifier ifNoJoinProposalPending(uint256 knightId) {
    uint clanId = _clanJoinProposal(knightId);
    if (clanId != 0) {
    //revert ClanModifiers_JoinProposalToSomeClanExists(knightId, clanId);
      revert("Clan Modifiers: Join Proposal To Some Clan Exists");
    }
    _;
  }

  function isClanOwner(uint256 knightId) internal view returns(bool) {
    return _roleInClan(knightId) == ClanRole.OWNER;
  }

  modifier ifNotClanOwner(uint knightId) {
    if (isClanOwner(knightId)) {
    //revert ClanModifiers_ClanOwnersCantCallThis(knightId);
      revert("Clan Modifiers: Clan Owners Can't Call This");
    }
    _;
  }

  modifier ifIsClanOwner(uint knightId) {
    if (!isClanOwner(knightId)) {
    //revert ClanModifiers_NotClanOwner(knightId);
      revert("Clan Modifiers: Not Clan Owner");
    }
    _;
  }

  function isClanAdmin(uint256 knightId) internal view returns(bool) {
    return _roleInClan(knightId) == ClanRole.ADMIN;
  }

  function isClanMod(uint256 knightId) internal view returns(bool) {
    return _roleInClan(knightId) == ClanRole.MOD;
  }

  function isBelowMaxMembers(uint256 clanId) internal view returns(bool) {
    return _clanTotalMembers(clanId) < _clanMaxMembers(clanId);
  }

  modifier ifIsBelowMaxMembers(uint256 clanId) {
    if (!isBelowMaxMembers(clanId)) {
    //revert ClanModifiers_AboveMaxMembers(clanId);
      revert("Clan Modifiers: Above Max Members");
    }
    _;
  }

  function isOnClanKickCooldown(uint knightId) internal view returns(bool) {
    return _clanKickCooldown(knightId) > block.timestamp;
  }

  modifier ifNotOnClanKickCooldown(uint knightId) {
    if (isOnClanKickCooldown(knightId)) {
    //revert ClanModifiers_KickingMembersOnCooldownForThisKnight(knightId);
      revert("Clan Modifiers: Kicking Members On Cooldown For This Knight");
    }
    _;
  }

  modifier ifNotClanNameTaken(string calldata clanName) {
    if(_clanNameTaken(clanName)) {
    //revert ClanModifiers_ClanNameTaken(clanName);
      revert("Clan Modifiers: Clan Name Taken");
    }
    _;
  }

  modifier ifIsClanNameCorrectLength(string calldata clanName) {
    //This is NOT a correct way to calculate string length, should change it later
    if(bytes(clanName).length < 1 || bytes(clanName).length > 30) {
    //revert ClanModifiers_ClanNameWrongLength(clanName);
      revert("Clan Modifiers: Clan Name Wrong Length");
    }
    _;
  }

  function isOnWithdrawalCooldown(uint256 clanId, address user) internal view returns(bool) {
    return _withdrawalCooldown(clanId, user) > block.timestamp;
  }

  modifier ifNotOnWithdrawalCooldown(uint256 clanId, address user) {
    if(isOnWithdrawalCooldown(clanId, user)) {
    //revert ClanModifiers_UserOnWithdrawalCooldown(user);
      revert("Clan Modifiers: User On Withdrawal Cooldown");
    }
    _;
  }

  function isBelowPendingWithdrawal(uint256 clanId, address user, uint256 amount) internal view returns(bool) {
    return _pendingWithdrawal(clanId, user) >= amount;
  }

  modifier ifIsBelowPendingWithdrawal(uint256 clanId, address user, uint256 amount) {
    if(!isBelowPendingWithdrawal(clanId, user, amount)) {
    //revert ClanModifiers_WithdrawalAbovePending(clanId, user, amount);
      revert("Clan Modifiers: Withdrawal Above Pending");
    }
    _;
  }

  function isBelowStake(uint256 clanId, address user, uint256 amount) internal view returns(bool) {
    return _stakeOf(clanId, user) >= amount;
  }

  modifier ifIsBelowStake(uint256 clanId, address user, uint256 amount) {
    if(!isBelowStake(clanId, user, amount)) {
    //revert ClanModifiers_WithdrawalAmountAboveStake(clanId, user, amount);
      revert("Clan Modifiers: Withdrawal Amount Above Stake");
    }
    _;
  }
}
