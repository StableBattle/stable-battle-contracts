// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.0;

import { KnightModifiers, KnightGetters} from "../storage/KnightStorage.sol";
import { Pool, Coin, ExternalCalls } from "../storage/MetaStorage.sol";

abstract contract DemoFightGetters {
  function userReward(address user) internal view virtual returns (uint256) {
    return DemoFightStorage.state().userReward[user];
  }
  
  function lockedYield() internal view virtual returns (uint256) {
    return DemoFightStorage.state().lockedYield;
  }
}

contract DemoFightFacet is DemoFightGetters, KnightGetters, ExternalCalls {
  using DemoFightStorage for DemoFightStorage.State;

  function battleWonBy(address user, uint256 reward) public {
    require(reward <= currentYield(),
      "DemoFightFacet: Can't assign reward bigger than the current yield");
    DemoFightStorage.state().userReward[user] += reward;
    DemoFightStorage.state().lockedYield += reward;
    emit NewWinner(user, reward);
  }

  function claimReward(address user) public {
    uint256 reward = userReward(user);
    DemoFightStorage.state().lockedYield -= reward;
    DemoFightStorage.state().userReward[user] = 0;
    AAVE().withdraw(address(USDC()), reward, user);
    emit RewardClaimed(user, reward);
  }

  function totalYield() internal view returns(uint256 totalStake) {
    (totalStake, , , , , ) = AAVE().getUserAccountData(address(this));
    totalStake /= 100;
  }

  function stakedByKnights() internal view returns(uint256) {
    return knightPrice(Coin.USDC) * knightsMinted(Pool.AAVE, Coin.USDC);
  }

  function currentYield() internal view returns(uint256 reward){
    return totalYield() - stakedByKnights() - lockedYield();
  }

//Public getters

  function getTotalYield() external view returns(uint256){
    return totalYield();
  }

  function getCurrentYield() external view returns(uint256){
    return currentYield();
  }

  function getLockedYield() external view returns(uint256) {
    return lockedYield();
  }

  function getStakedByKnights() external view returns(uint256){
    return stakedByKnights();
  }

  function getUserReward(address user) external view returns(uint256) {
    return userReward(user);
  }
//Events
  event NewWinner(address user, uint256 reward);
  event RewardClaimed(address user, uint256 reward);
}

library DemoFightStorage {
  struct State {
    mapping (address => uint256) userReward;
    uint256 lockedYield;
  }

  bytes32 internal constant STORAGE_SLOT = keccak256("DemoFight.storage");

  function state() internal pure returns (State storage l) {
    bytes32 slot = STORAGE_SLOT;
    assembly {
      l.slot := slot
    }
  }
}
