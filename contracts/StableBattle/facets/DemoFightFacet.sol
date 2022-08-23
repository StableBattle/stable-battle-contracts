// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.0;

import { KnightModifiers, KnightGetters} from "../storage/KnightStorage.sol";
import { Pool, Coin, ExternalCalls, MetaModifiers } from "../storage/MetaStorage.sol";

abstract contract DemoFightGetters is KnightGetters, ExternalCalls {
  function currentYield() internal view returns(uint256, uint256) {
    (uint256 totalYieldUSDT, uint256 totalYieldUSDC) = totalYield();
    (uint256 knightStakeUSDT, uint256 knightStakeUSDC) = stakedByKnights();
    (uint256 lockedYieldUSDT, uint256 lockedYieldUSDC) = lockedYield();
    return (totalYieldUSDT - knightStakeUSDT - lockedYieldUSDT, 
            totalYieldUSDC - knightStakeUSDC - lockedYieldUSDC);
  }

  function totalYield() internal view returns(uint256, uint256) {
    return (ACOIN(Coin.USDT).balanceOf(address(this)),
            ACOIN(Coin.USDC).balanceOf(address(this)));
  }
  
  function lockedYield() internal view virtual returns (uint256, uint256) {
    return (DemoFightStorage.state().lockedYield[Pool.AAVE][Coin.USDT],
            DemoFightStorage.state().lockedYield[Pool.AAVE][Coin.USDC]);
  }

  function stakedByKnights() internal view returns(uint256 stakeUSDT, uint256 stakeUSDC) {
    stakeUSDT = knightPrice(Coin.USDT) * (knightsMinted(Pool.AAVE, Coin.USDT) - knightsBurned(Pool.AAVE, Coin.USDT));
    stakeUSDC = knightPrice(Coin.USDC) * (knightsMinted(Pool.AAVE, Coin.USDC) - knightsBurned(Pool.AAVE, Coin.USDC));
  }

  function userReward(address user) internal view virtual returns (uint256, uint256) {
    return (DemoFightStorage.state().userReward[user][Coin.USDT],
            DemoFightStorage.state().userReward[user][Coin.USDC]);
  }
}

contract DemoFightFacet is KnightGetters, ExternalCalls, DemoFightGetters, MetaModifiers {
  using DemoFightStorage for DemoFightStorage.State;

  function battleWonBy(address user, uint256 rewardUSDT, uint256 rewardUSDC) public {
    (uint256 currentYieldUSDT, uint256 currentYieldUSDC) = currentYield();
    require(rewardUSDT <= currentYieldUSDT, 
      "DemoFightFacet: Can't assign USDT reward bigger than the current yield");
    require(rewardUSDC <= currentYieldUSDC, 
      "DemoFightFacet: Can't assign USDC reward bigger than the current yield");
    DemoFightStorage.state().userReward[user][Coin.USDT] += rewardUSDT;
    DemoFightStorage.state().userReward[user][Coin.USDC] += rewardUSDC;
    DemoFightStorage.state().lockedYield[Pool.AAVE][Coin.USDT] += rewardUSDT;
    DemoFightStorage.state().lockedYield[Pool.AAVE][Coin.USDC] += rewardUSDC;
    emit NewWinner(user, rewardUSDT, rewardUSDC);
  }

  function claimReward(address user) public {
    (uint256 rewardUSDT, uint256 rewardUSDC) = userReward(user);
    DemoFightStorage.state().lockedYield[Pool.AAVE][Coin.USDT] -= rewardUSDT;
    DemoFightStorage.state().lockedYield[Pool.AAVE][Coin.USDC] -= rewardUSDC;
    DemoFightStorage.state().userReward[user][Coin.USDT] = 0;
    DemoFightStorage.state().userReward[user][Coin.USDC] = 0;
    AAVE().withdraw(address(USDT()), rewardUSDT, user);
    AAVE().withdraw(address(USDC()), rewardUSDC, user);
    emit RewardClaimed(user, rewardUSDT, rewardUSDC);
  }

//External getters

  function getTotalYield() external view returns(uint256, uint256) {
    return totalYield();
  }

  function getCurrentYield() external view returns(uint256, uint256) {
    return currentYield();
  }

  function getLockedYield() external view returns(uint256, uint256) {
    return lockedYield();
  }

  function getStakedByKnights() external view returns(uint256, uint256) {
    return stakedByKnights();
  }

  function getUserReward(address user) external view returns(uint256, uint256) {
    return userReward(user);
  }

  function getYieldInfo()
    external
    view
    returns(uint256, uint256, uint256, uint256, uint256, uint256, uint256, uint256)
  {
    (uint256 currentYieldUSDT, uint256 currentYieldUSDC) = currentYield();
    (uint256 totalYieldUSDT, uint256 totalYieldUSDC) = totalYield();
    (uint256 lockedYieldUSDT, uint256 lockedYieldUSDC) = lockedYield();
    (uint256 stakedByKnightsUSDT, uint256 stakedByKnightsUSDC) = stakedByKnights();
    return(currentYieldUSDT, currentYieldUSDC,
           totalYieldUSDT, totalYieldUSDC,
           lockedYieldUSDT, lockedYieldUSDC,
           stakedByKnightsUSDT, stakedByKnightsUSDC);
  }
  
//Events

  event NewWinner(address user, uint256 rewardUSDT, uint256 rewardUSDC);
  event RewardClaimed(address user, uint256 rewardUSDT, uint256 rewardUSDC);
}

library DemoFightStorage {
  struct State {
    mapping (address => mapping (Coin => uint256)) userReward;
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
