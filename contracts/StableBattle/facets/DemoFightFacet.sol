// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.0;

import { KnightModifiers, KnightGetters} from "../storage/KnightStorage.sol";
import { Pool, Coin, ExternalCalls, MetaModifiers } from "../storage/MetaStorage.sol";

abstract contract DemoFightGetters is KnightGetters, ExternalCalls {
  function currentYield() internal view returns(uint256) {
    return totalYield() - stakedByKnights() - lockedYield();
  }

  function totalYield() internal view returns(uint256) {
    return ACOIN(Coin.USDT).balanceOf(address(this));
  }
  
  function lockedYield() internal view virtual returns (uint256) {
    return DemoFightStorage.state().lockedYield[Pool.AAVE][Coin.USDT];
  }

  function stakedByKnights() internal view returns(uint256) {
    return knightPrice(Coin.USDT) * (knightsMinted(Pool.AAVE, Coin.USDT) - knightsBurned(Pool.AAVE, Coin.USDT));
  }

  function userReward(address user) internal view virtual returns (uint256) {
    return DemoFightStorage.state().userReward[user][Pool.AAVE][Coin.USDT];
  }
}

contract DemoFightFacet is KnightGetters, ExternalCalls, DemoFightGetters, MetaModifiers {
  using DemoFightStorage for DemoFightStorage.State;

  function battleWonBy(address user, uint256 reward) public {
    require(reward <= currentYield(), 
      "DemoFightFacet: Can't assign reward bigger than the current yield");
    DemoFightStorage.state().userReward[user][Pool.AAVE][Coin.USDT] += reward;
    DemoFightStorage.state().lockedYield[Pool.AAVE][Coin.USDT] += reward;
    emit NewWinner(user, reward);
  }

  function claimReward(address user) public {
    uint256 reward = userReward(user);
    DemoFightStorage.state().lockedYield[Pool.AAVE][Coin.USDT] -= reward;
    DemoFightStorage.state().userReward[user][Pool.AAVE][Coin.USDT] = 0;
    AAVE().withdraw(address(COIN(Coin.USDT)), reward, user);
    emit RewardClaimed(user, reward);
  }

//External getters

  function getTotalYield() external view returns(uint256) {
    return totalYield();
  }

  function getCurrentYield() external view returns(uint256) {
    return currentYield();
  }

  function getLockedYield() external view returns(uint256) {
    return lockedYield();
  }

  function getStakedByKnights() external view returns(uint256) {
    return stakedByKnights();
  }

  function getUserReward(address user) external view returns(uint256) {
    return userReward(user);
  }

  function getYieldInfo()
    external
    view
    returns(uint256, uint256, uint256, uint256)
  {
    return(
      currentYield(),
      totalYield(),
      lockedYield(),
      stakedByKnights()
    );
  }
  
//Events

  event NewWinner(address user, uint256 reward);
  event RewardClaimed(address user, uint256 reward);
}

library DemoFightStorage {
  struct State {
    mapping (address => mapping (Pool => mapping (Coin => uint256))) userReward;
    mapping (Pool => mapping (Coin => uint256)) lockedYield;
  }

  bytes32 internal constant STORAGE_SLOT = keccak256("DemoFight.storage");

  function state() internal pure returns (State storage l) {
    bytes32 slot = STORAGE_SLOT;
    assembly {
      l.slot := slot
    }
  }
}
