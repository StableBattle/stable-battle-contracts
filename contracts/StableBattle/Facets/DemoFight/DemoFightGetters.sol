// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.0;

import { Pool, Coin } from "../../Meta/DataStructures.sol";

import { KnightGetters } from "../Knight/KnightGetters.sol";
import { ExternalCalls } from "../../Meta/ExternalCalls.sol";
import { DemoFightStorage } from "./DemoFightStorage.sol";
import { IDemoFightGetters } from "../DemoFight/IDemoFight.sol";

abstract contract DemoFightGetters is KnightGetters, ExternalCalls {
  function _currentYield() internal view returns(uint256) {
    return _totalYield() - _stakedByKnights() - _lockedYield();
  }

  function _totalYield() internal view returns(uint256) {
    return ACOIN(Coin.USDT).balanceOf(address(this));
  }
  
  function _lockedYield() internal view virtual returns (uint256) {
    return DemoFightStorage.state().lockedYield[Pool.AAVE][Coin.USDT];
  }

  function _stakedByKnights() internal view returns(uint256) {
    return _knightPrice(Coin.USDT) * (_knightsMinted(Pool.AAVE, Coin.USDT) - _knightsBurned(Pool.AAVE, Coin.USDT));
  }

  function _userReward(address user) internal view virtual returns (uint256) {
    return DemoFightStorage.state().userReward[user][Pool.AAVE][Coin.USDT];
  }
}

abstract contract DemoFightGettersExternal is IDemoFightGetters, DemoFightGetters {
  function getTotalYield() external view returns(uint256) {
    return _totalYield();
  }

  function getCurrentYield() external view returns(uint256) {
    return _currentYield();
  }

  function getLockedYield() external view returns(uint256) {
    return _lockedYield();
  }

  function getStakedByKnights() external view returns(uint256) {
    return _stakedByKnights();
  }

  function getUserReward(address user) external view returns(uint256) {
    return _userReward(user);
  }

  function getYieldInfo()
    external
    view
    returns(uint256, uint256, uint256, uint256)
  {
    return(
      _currentYield(),
      _totalYield(),
      _lockedYield(),
      _stakedByKnights()
    );
  }
}
