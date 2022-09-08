// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.0;

import { Pool, Coin } from "../storage/MetaStorage.sol";

contract DemoFightFacetDummy {

  function battleWonBy(address user, Pool pool, Coin coin, uint256 reward) external {}

  function claimReward(address user, Pool pool, Coin coin) external {}

//External getters

  function getTotalYield(Pool pool, Coin coin) external view returns(uint256) {}

  function getCurrentYield(Pool pool, Coin coin) external view returns(uint256) {}

  function getLockedYield(Pool pool, Coin coin) external view returns(uint256) {}

  function getStakedByKnights(Pool pool, Coin coin) external view returns(uint256) {}

  function getUserReward(address user, Pool pool, Coin coin) external view returns(uint256) {}

  function getYieldInfo(Pool pool, Coin coin)
    external
    view
    returns(uint256, uint256, uint256, uint256)
  {}
  
//Events

  event NewWinner(address user, uint256 reward);
  event RewardClaimed(address user, uint256 reward);
}