// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.0;

import { KnightModifiers, KnightGetters} from "../storage/KnightStorage.sol";
import { Pool, Coin, ExternalCalls, MetaModifiers } from "../storage/MetaStorage.sol";

abstract contract DemoFightGetters is KnightGetters, ExternalCalls {
  function currentYield(Pool pool, Coin coin) internal view returns(uint256) {
    return totalYield(pool, coin) - stakedByKnights(pool, coin) - lockedYield(pool, coin);
  }

  function totalYield(Pool pool, Coin coin) internal view returns(uint256) {
    return pool == Pool.AAVE ? ACOIN(coin).balanceOf(address(this)) : 0;
  }
  
  function lockedYield(Pool pool, Coin coin) internal view virtual returns (uint256) {
    return DemoFightStorage.state().lockedYield[pool][coin];
  }

  function stakedByKnights(Pool pool, Coin coin) internal view returns(uint256) {
    return knightPrice(coin) * (knightsMinted(pool, coin) - knightsBurned(pool, coin));
  }

  function userReward(address user, Pool pool, Coin coin) internal view virtual returns (uint256) {
    return DemoFightStorage.state().userReward[user][pool][coin];
  }
}

contract DemoFightFacet is KnightGetters, ExternalCalls, DemoFightGetters, MetaModifiers {
  using DemoFightStorage for DemoFightStorage.State;

  function battleWonBy(
    address user, 
    Pool pool, 
    Coin coin, 
    uint256 reward)
  public
  //onlyAdmin
  {
    require(reward <= currentYield(pool, coin), 
      "DemoFightFacet: Can't assign reward bigger than the current yield");
    DemoFightStorage.state().userReward[user][pool][coin] += reward;
    DemoFightStorage.state().lockedYield[pool][coin] += reward;
    emit NewWinner(user, reward, pool, coin);
  }

  function claimReward(address user, Pool pool, Coin coin) public {
    uint256 reward = userReward(user, pool, coin);
    DemoFightStorage.state().lockedYield[pool][coin] -= reward;
    DemoFightStorage.state().userReward[user][pool][coin] = 0;
    AAVE().withdraw(address(COIN(coin)), reward, user);
    emit RewardClaimed(user, reward, pool, coin);
  }

//External getters

  function getTotalYield(Pool pool, Coin coin) external view returns(uint256) {
    return totalYield(pool, coin);
  }

  function getCurrentYield(Pool pool, Coin coin) external view returns(uint256) {
    return currentYield(pool, coin);
  }

  function getLockedYield(Pool pool, Coin coin) external view returns(uint256) {
    return lockedYield(pool, coin);
  }

  function getStakedByKnights(Pool pool, Coin coin) external view returns(uint256) {
    return stakedByKnights(pool, coin);
  }

  function getUserReward(address user, Pool pool, Coin coin) external view returns(uint256) {
    return userReward(user, pool, coin);
  }

  function getYieldInfo(Pool pool, Coin coin)
    external
    view
    returns(uint256, uint256, uint256, uint256)
  {
    return(
      currentYield(pool, coin),
      totalYield(pool, coin),
      lockedYield(pool, coin),
      stakedByKnights(pool, coin)
    );
  }
  
//Events

  event NewWinner(address user, uint256 reward, Pool pool, Coin coin);
  event RewardClaimed(address user, uint256 reward, Pool pool, Coin coin);
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
