// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.0;

contract DemoFightFacetDummy {

  function battleWonBy(address user, uint256 reward) public {}

  function claimReward(address user) public {}

//Public getters

  function getTotalYield() external view returns(uint256) {}

  function getCurrentYield() external view returns(uint256) {}

  function getLockedYield() external view returns(uint256) {}

  function getStakedByKnights() public view returns(uint256) {}

  function getUserReward(address user) external view returns(uint256) {}
  
  function getStakeInfo() external view returns(uint256, uint256, uint256, uint256) {}

//Events
  event NewWinner(address user, uint256 reward);
  event RewardClaimed(address user, uint256 reward);
}
