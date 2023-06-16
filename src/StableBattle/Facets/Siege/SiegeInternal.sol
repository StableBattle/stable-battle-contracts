// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.0;

import { SiegeStorage } from "../Siege/SiegeStorage.sol";
import { ClanStorage } from "../Clan/ClanStorage.sol";

contract SiegeInternal {
  function _setSiegeWinnerKnight(uint256 clanId) internal returns(uint256 knightId) {
    knightId = ClanStorage.layout().clanLeader[clanId];
    SiegeStorage.layout().siegeWinnerKnight = knightId;
  }
}