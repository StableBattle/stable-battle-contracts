// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.0;

contract DemoFightFacetDummy {

//State-affecting operations

  function battleWonBy(address user, uint256 rewardUSDT, uint256 rewardUSDC) public {}

  function claimReward(address user) public {}

//External getters

  function getTotalYield() external view returns(uint256, uint256) {}

  function getCurrentYield() external view returns(uint256, uint256) {}

  function getLockedYield() external view returns(uint256, uint256) {}

  function getStakedByKnights() external view returns(uint256, uint256) {}

  function getUserReward(address user) external view returns(uint256, uint256) {}
  function getYieldInfo()
    external
    view
    returns(uint256, uint256, uint256, uint256, uint256, uint256, uint256, uint256)
  {}
  
//Events

  event NewWinner(address user, uint256 rewardUSDT, uint256 rewardUSDC);
  event RewardClaimed(address user, uint256 rewardUSDT, uint256 rewardUSDC);
}