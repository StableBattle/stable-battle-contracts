// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.0;

import { ClanGetters } from "../Clan/ClanGetters.sol";
import { EnumerableSet } from "@solidstate/contracts/utils/EnumerableSet.sol";
import { ERC1155EnumerableStorage } from "@solidstate/contracts/token/ERC1155/enumerable/ERC1155EnumerableStorage.sol";

import { SiegeStorage } from "../Siege/SiegeStorage.sol";

contract SiegeInternal is ClanGetters {
  function _setSiegeWinnerKnight(uint256 clanId) internal returns(uint256 knightId) {
    knightId = _clanLeader(clanId);
    SiegeStorage.state().siegeWinnerKnight = knightId;
  }
}