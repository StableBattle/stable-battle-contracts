// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.0;

import { SiegeStorage } from "../Siege/SiegeStorage.sol";
import { KnightStorage } from "../Knight/KnightStorage.sol";
import { ISiegeGetters } from "../Siege/ISiege.sol";
import { ExternalCalls } from "../../Meta/ExternalCalls.sol";
import { Pool, Coin } from "../../Meta/DataStructures.sol";

abstract contract SiegeGettersExternal is ISiegeGetters, ExternalCalls {
  function getSiegeRewardTotal() external view returns(uint256) {
    return SiegeStorage.layout().rewardTotal;
  }

  function getSiegeReward(address user) external view returns(uint256) {
    return SiegeStorage.layout().reward[user];
  }

  function getSiegeWinnerClanId() external view returns(uint256) {
    return SiegeStorage.layout().siegeWinnerClan;
  }

  function getSiegeWinnerKnightId() external view returns(uint256) {
    return SiegeStorage.layout().siegeWinnerKnight;
  }

  function getSiegeWinnerAddress() external view returns(address) {
    return SiegeStorage.layout().siegeWinnerAddress;
  }

  function getSiegeWinnerInfo() external view returns(uint256, uint256) {
    return (SiegeStorage.layout().siegeWinnerClan, SiegeStorage.layout().siegeWinnerKnight);
  }

  function getSiegeYield() external view returns(uint256) {
    return SiegeStorage.siegeYield();
  }

  function getYieldTotal() external view returns(uint256) {
    return ACOIN(Coin.USDT).balanceOf(address(this));
  }
}