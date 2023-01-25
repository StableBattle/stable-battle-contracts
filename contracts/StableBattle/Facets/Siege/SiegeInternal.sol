// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.0;

import { ClanGetters } from "../Clan/ClanGetters.sol";
import { EnumerableSet } from "@solidstate/contracts/utils/EnumerableSet.sol";
import { ERC1155EnumerableStorage } from "@solidstate/contracts/token/ERC1155/enumerable/ERC1155EnumerableStorage.sol";

import { SiegeStorage } from "../Siege/SiegeStorage.sol";

contract SiegeInternal is ClanGetters {
  using EnumerableSet for EnumerableSet.AddressSet;

  function _setSiegeWinnerKnight(uint256 clanId) internal returns(uint256 knightId) {
    knightId = _clanLeader(clanId);
    SiegeStorage.state().siegeWinnerKnight = knightId;
  }

  function _setSiegeWinnerAddress(uint256 knightId) internal returns(address winner) {
    uint256 id = knightId;
    //Below is a copy of _accountsByToken from ERC1155EnumerableInternal 
    //since I don't want to deal with inheritance overrides bloat
      EnumerableSet.AddressSet storage accounts = ERC1155EnumerableStorage
        .layout()
        .accountsByToken[id];

      address[] memory addresses = new address[](accounts.length());

      unchecked {
        for (uint256 i; i < accounts.length(); i++) {
          addresses[i] = accounts.at(i);
        }
      }
    //End of copy
    winner = addresses[0];
    SiegeStorage.state().siegeWinnerAddress = winner;
  }
}