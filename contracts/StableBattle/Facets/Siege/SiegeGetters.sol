// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.0;

import { SiegeStorage } from "../Siege/SiegeStorage.sol";
import { KnightStorage } from "../Knight/KnightStorage.sol";
import { ISiegeGetters } from "../Siege/ISiege.sol";
import { ExternalCalls } from "../../Meta/ExternalCalls.sol";
import { Pool, Coin } from "../../Meta/DataStructures.sol";

abstract contract SiegeGetters is ExternalCalls {
  function _siegeRewardTotal() internal view returns(uint256) {
    return SiegeStorage._siegeRewardTotal();
  }

  function _siegeReward(address user) internal view returns(uint256) {
    return SiegeStorage._siegeReward(user);
  }

  function _siegeWinnerClan() internal view returns(uint256) {
    return SiegeStorage._siegeWinnerClan();
  }

  function _siegeWinnerKnight() internal view returns(uint256) {
    return SiegeStorage._siegeWinnerKnight();
  }

  function _siegeWinnerAddress() internal view returns(address) {
    return SiegeStorage._siegeWinnerAddress();
  }

  function _siegeYield() internal view returns(uint256) {
    uint256 stakeTotal = ACOIN(Coin.USDT).balanceOf(address(this));
    uint256 knightStake = 
      (
        KnightStorage.state().knightsMinted[Pool.AAVE][Coin.USDT] - 
        KnightStorage.state().knightsBurned[Pool.AAVE][Coin.USDT]
      ) * 1e9;
    return stakeTotal - knightStake - _siegeRewardTotal();
  }
} 

abstract contract SiegeGettersExternal is ISiegeGetters, SiegeGetters {
  function getSiegeRewardTotal() external view returns(uint256) {
    return _siegeRewardTotal();
  }

  function getSiegeReward(address user) external view returns(uint256) {
    return _siegeReward(user);
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
    return _siegeYield();
  }

  function getYieldTotal() external view returns(uint256) {
    return ACOIN(Coin.USDT).balanceOf(address(this));
  }
}