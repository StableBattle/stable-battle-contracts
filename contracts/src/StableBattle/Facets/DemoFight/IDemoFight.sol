// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.0;

import { IDemoFightEvents } from "./IDemoFightEvents.sol";
import { IDemoFightErrors } from "./IDemoFightErrors.sol";

interface IDemoFight is IDemoFightEvents, IDemoFightErrors {

  function battleWonBy(address user, uint256 reward) external;

  function claimReward(address user) external;

//External getters

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