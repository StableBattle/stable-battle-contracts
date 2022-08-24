// SPDX-License-Identifier: Unlicensed

pragma solidity ^0.8.0;

import { ClanStorage, Clan, Proposal } from "../Clan/ClanStorage.sol";

abstract contract ClanModifiers {
  using ClanStorage for ClanStorage.State;
  
  function clanExists(uint256 clanId) internal view returns(bool) {
    return ClanStorage.state().clan[clanId].leader != 0;
  }

  modifier ifClanExists(uint256 clanId) {
    require(clanExists(clanId),
      "ClanModifiers: This clan doesn't exist");
    _;
  }

  function isClanLeader(uint256 knightId, uint256 clanId) internal view returns(bool) {
    return ClanStorage.state().clan[clanId].leader == knightId;
  }

  modifier ifIsClanLeader(uint256 knightId, uint clanId) {
    require(isClanLeader(knightId, clanId), 
      "ClanModifiers: This knight is doesn't own this clan");
    _;
  }

  function isNotClanLeader(uint256 knightId, uint256 clanId) internal view returns(bool) {
    return ClanStorage.state().clan[clanId].leader != knightId;
  }

  modifier ifIsNotClanLeader(uint256 knightId, uint clanId) {
    require(isNotClanLeader(knightId, clanId), 
      "ClanModifiers: This knight is already owns this clan");
    _;
  }
}
