// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.0;

import { Pool, Coin } from "../../Meta/DataStructures.sol";

import { IDemoFightEvents, IDemoFightErrors } from "./IDemoFight.sol";
import { DemoFightGetters } from "./DemoFightGetters.sol";
import { DemoFightStorage } from "./DemoFightStorage.sol";

abstract contract DemoFightInternal is IDemoFightEvents, IDemoFightErrors, DemoFightGetters {
  function _battleWonBy(address user, uint256 reward) public {
    uint256 currentYield = _currentYield();
    if(reward > currentYield) {
      revert DemoFightFacet_RewardBiggerThanYield(reward, currentYield);
    }
    DemoFightStorage.state().userReward[user][Pool.AAVE][Coin.USDT] += reward;
    DemoFightStorage.state().lockedYield[Pool.AAVE][Coin.USDT] += reward;
    emit NewWinner(user, reward);
  }

  function _claimReward(address user) public {
    uint256 reward = _userReward(user);
    DemoFightStorage.state().lockedYield[Pool.AAVE][Coin.USDT] -= reward;
    DemoFightStorage.state().userReward[user][Pool.AAVE][Coin.USDT] = 0;
    AAVE().withdraw(address(COIN(Coin.USDT)), reward, user);
    emit RewardClaimed(user, reward);
  }
}