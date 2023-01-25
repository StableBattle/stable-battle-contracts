// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.0;

import { SiegeStorage } from "../Siege/SiegeStorage.sol";
import { ClanGetters } from "../Clan/ClanGetters.sol";
import { ERC1155EnumerableStorage } from "@solidstate/contracts/token/ERC1155/enumerable/ERC1155EnumerableStorage.sol";
import { ERC1155BaseInternal } from "@solidstate/contracts/token/ERC1155/base/ERC1155BaseInternal.sol";
import { EnumerableSet } from "@solidstate/contracts/utils/EnumerableSet.sol";

abstract contract SiegeGetters {
  function _siegeReward(uint256 knightId) internal view returns(uint256) {
    return SiegeStorage.state().reward[knightId];
  }

  function _siegeWinnerClan() internal view returns(uint256) {
    return SiegeStorage.state().siegeWinnerClan;
  }
}

abstract contract SiegeGettersExternal is SiegeGetters, ClanGetters {
  using EnumerableSet for EnumerableSet.AddressSet;

  function getSiegeReward(uint256 knightId) external view returns(uint256) {
    return _siegeReward(knightId);
  }

  function getSiegeWinnerClanId() external view returns(uint256) {
    return _siegeWinnerClan();
  }

  function getSiegeWinnerKnightId() external view returns(uint256) {
    return _clanLeader(_siegeWinnerClan());
  }

  function getSiegeWinnerAddress() public view returns(address) {
    uint256 clanWinnerId = _siegeWinnerClan();
    uint256 clanLeaderId = _clanLeader(clanWinnerId);
    //Below is a copy of _accountsByToken from ERC1155EnumerableInternal 
    //since I don't want to deal with inheritance overrides bloat
      uint256 id = clanLeaderId;
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
    return addresses[0];
  }

  function getSiegeWinnerInfo() external view returns(uint256, uint256, address) {
    uint256 clanWinnerId = _siegeWinnerClan();
    uint256 clanLeaderId = _clanLeader(clanWinnerId);
    address clanLeaderHolder = getSiegeWinnerAddress();
    return (clanWinnerId, clanLeaderId, clanLeaderHolder);
  }
}