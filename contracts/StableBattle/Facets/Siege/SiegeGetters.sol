// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.0;

import { ClanGetters } from "../Clan/ClanGetters.sol";

import { SiegeStorage } from "../Siege/SiegeStorage.sol";
import { ISiegeGetters } from "../Siege/ISiege.sol";

abstract contract SiegeGetters {
  function _siegeReward(uint256 knightId) internal view returns(uint256) {
    return SiegeStorage.state().reward[knightId];
  }

  function _siegeWinnerClan() internal view returns(uint256) {
    return SiegeStorage.state().siegeWinnerClan;
  }

  function _siegeWinnerKnight() internal view returns(uint256) {
    return SiegeStorage.state().siegeWinnerKnight;
  }

  function _siegeWinnerAddress() internal view returns(address) {
    return SiegeStorage.state().siegeWinnerAddress;
  }
}

abstract contract SiegeGettersExternal is ISiegeGetters, SiegeGetters, ClanGetters {
  function getSiegeReward(uint256 knightId) external view returns(uint256) {
    return _siegeReward(knightId);
  }

  function getSiegeWinnerClanId() external view returns(uint256) {
    return _siegeWinnerClan();
  }

  function getSiegeWinnerKnightId() external view returns(uint256) {
    return _siegeWinnerKnight();
  }

  function getSiegeWinnerAddress() external view returns(address) {
    return _siegeWinnerAddress();
  }

  function getSiegeWinnerInfo() external view returns(uint256, uint256, address) {
    return (_siegeWinnerClan(), _siegeWinnerKnight(), _siegeWinnerAddress());
  }
}