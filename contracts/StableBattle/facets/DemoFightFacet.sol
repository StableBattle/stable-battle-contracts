// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.0;

import { KnightModifiers, KnightGetters} from "../storage/KnightStorage.sol";
import { Pool, Coin, ExternalCalls, MetaModifiers } from "../storage/MetaStorage.sol";

abstract contract DemoFightGetters {
  function userReward(address user) internal view virtual returns (uint256) {
    return DemoFightStorage.state().userReward[user];
  }
  
  function lockedYield() internal view virtual returns (uint256) {
    return DemoFightStorage.state().lockedYield;
  }
}

contract DemoFightFacet is DemoFightGetters, KnightGetters, ExternalCalls, MetaModifiers {
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

//Internal getters

  function totalYield() internal view returns(uint256 yield) {
    for (uint8 p = 1; p < uint8(type(Pool).max) + 1; p++) {
      for (uint8 c = 1; c < uint8(type(Coin).max) + 1; c++) {
        if (isCompatible(Pool(p), Coin(c)) && 
            Pool(p) != Pool.TEST && Coin(c) != Coin.TEST) {
          yield += ACOIN(Coin(c)).balanceOf(address(this));
        }
      } 
    }
  }

  function stakedByKnights() internal view returns(uint256 stake) {
    for (uint8 p = 1; p < uint8(type(Pool).max) + 1; p++) {
      for (uint8 c = 1; c < uint8(type(Coin).max) + 1; c++) {
        if (isCompatible(Pool(p), Coin(c))) {
          stake += knightPrice(Coin(c)) * knightsMinted(Pool(p), Coin(c));
        }
      }
    }
  }

  function currentYield() internal view returns(uint256 reward){
    return totalYield() - stakedByKnights() - lockedYield();
  }

//External getters

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

  function getStakeInfo() external view returns(uint256, uint256, uint256, uint256) {
    return(currentYield(), totalYield(), lockedYield(), stakedByKnights());
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
