// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.0;

import { SiegeStorage } from "../Siege/SiegeStorage.sol";
import { ISiegeGetters } from "../Siege/ISiege.sol";
import { ExternalCalls } from "../../Meta/ExternalCalls.sol";
import { Coin } from "../../Meta/DataStructures.sol";

abstract contract SiegeGetters {
  function _siegeRewardTotal() internal view returns(uint256) {
    return SiegeStorage.state().rewardTotal;
  }

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

abstract contract SiegeGettersExternal is ISiegeGetters, SiegeGetters, ExternalCalls {
  function getSiegeRewardTotal() external view returns(uint256) {
    return _siegeRewardTotal();
  }

  function getSiegeReward(uint256 knightId) external view returns(uint256) {
    return _siegeReward(knightId);
  }

  function getSiegeWinnerClanId() external view returns(uint256) {
    return _siegeWinnerClan();
  }

  function getSiegeWinnerKnightId() external view returns(uint256) {
    return _siegeWinnerKnight();
  }

  function getSiegeWinnerInfo() external view returns(uint256, uint256) {
    return (_siegeWinnerClan(), _siegeWinnerKnight());
  }

  function getSiegeYield() external view returns(uint256) {
    return ACOIN(Coin.USDT).balanceOf(address(this));
  }
}