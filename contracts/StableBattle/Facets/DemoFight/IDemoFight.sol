// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.0;

interface IDemoFightEvents {
  event NewWinner(address user, uint256 reward);
  event RewardClaimed(address user, uint256 reward);
}

interface IDemoFightErrors {
  error DemoFightFacet_RewardBiggerThanYield(uint256 reward, uint256 currentYield);
}

interface IDemoFightGetters {
  function getTotalYield() external view returns(uint256);

  function getCurrentYield() external view returns(uint256);

  function getLockedYield() external view returns(uint256);

  function getStakedByKnights() external view returns(uint256);

  function getUserReward(address user) external view returns(uint256);

  function getYieldInfo()
    external
    view
    returns(uint256, uint256, uint256, uint256);
}

interface IDemoFight is IDemoFightEvents, IDemoFightErrors, IDemoFightGetters {
  function battleWonBy(address user, uint256 reward) external;

  function claimReward(address user) external;
}