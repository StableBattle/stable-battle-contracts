// SPDX-License-Identifier: Unlicensed

pragma solidity ^0.8.0;

import { Clan, ClanRole } from "../../Meta/DataStructures.sol";
import { ClanStorage } from "../Clan/ClanStorage.sol";
import { IClanErrors } from "../Clan/IClan.sol";
import { ClanGetters } from "../Clan/ClanGetters.sol";

abstract contract ClanModifiers is IClanErrors, ClanGetters {
  function clanExists(uint256 clanId) internal view returns(bool) {
    return ClanStorage.state().clan[clanId].leader != 0;
  }

  modifier ifClanExists(uint256 clanId) {
    if(!clanExists(clanId)) {
      revert ClanModifiers_ClanDoesntExist(clanId);
    }
    _;
  }

  function isClanLeader(uint256 knightId, uint256 clanId) internal view returns(bool) {
    return ClanStorage.state().clan[clanId].leader == knightId;
  }

  modifier ifIsClanLeader(uint256 knightId, uint clanId) {
    if(!isClanLeader(knightId, clanId)) {
      revert ClanModifiers_KnightIsNotClanLeader(knightId, clanId);
    }
    _;
  }

  function isNotClanLeader(uint256 knightId, uint256 clanId) internal view returns(bool) {
    return ClanStorage.state().clan[clanId].leader != knightId;
  }

  modifier ifIsNotClanLeader(uint256 knightId, uint clanId) {
    if(!isNotClanLeader(knightId, clanId)) {
      revert ClanModifiers_KnightIsClanLeader(knightId, clanId);
    }
    _;
  }

  function isOnClanActivityCooldown(uint256 knightId) internal view returns(bool) {
    return _clanActivityCooldown(knightId) > block.timestamp;
  }

  modifier ifIsNotOnClanActivityCooldown(uint256 knightId) {
    if (isOnClanActivityCooldown(knightId)) {
      revert ClanModifiers_KnightOnClanActivityCooldown(knightId);
    }
    _;
  }

  function isJoinProposalPending(uint256 knightId) internal view returns(bool) {
    return _clanJoinProposal(knightId) != 0;
  }

  modifier ifNoJoinProposalPending(uint256 knightId) {
    uint clanId = _clanJoinProposal(knightId);
    if (clanId != 0) {
      revert ClanModifiers_JoinProposalToSomeClanExists(knightId, clanId);
    }
    _;
  }

  function isClanOwner(uint256 knightId) internal view returns(bool) {
    return _roleInClan(knightId) == ClanRole.OWNER;
  }

  modifier ifNotClanOwner(uint knightId) {
    if (isClanOwner(knightId)) {
      revert ClanModifiers_ClanOwnersCantCallThis(knightId);
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
      revert ClanModifiers_AboveMaxMembers(clanId);
    }
    _;
  }

  function isOnClanKickCooldown(uint knightId) internal view returns(bool) {
    return _clanKickCooldown(knightId) < block.timestamp;
  }

  modifier ifNotOnClanKickCooldown(uint knightId) {
    if (isOnClanKickCooldown(knightId)) {
      revert ClanModifiers_KickingMembersOnCooldownForThisKnight(knightId);
    }
    _;
  }

  modifier ifNotClanNameTaken(string calldata clanName) {
    if(_clanNameTaken(clanName)) {
      revert ClanModifiers_ClanNameTaken(clanName);
    }
    _;
  }

  modifier ifIsClanNameCorrectLength(string calldata clanName) {
    //This is NOT a correct way to calculate string length, should change it later
    if(bytes(clanName).length < 1 || bytes(clanName).length > 30) {
      revert ClanModifiers_ClanNameWrongLength(clanName);
    }
    _;
  }
}
