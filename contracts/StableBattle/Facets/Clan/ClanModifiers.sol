// SPDX-License-Identifier: Unlicensed

pragma solidity ^0.8.0;

import { Clan, Proposal } from "../../Meta/DataStructures.sol";
import { ClanStorage } from "../Clan/ClanStorage.sol";
import { IClanErrors } from "../Clan/IClan.sol";

abstract contract ClanModifiers is IClanErrors {
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
}
