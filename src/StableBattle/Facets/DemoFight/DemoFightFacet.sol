// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.0;

import { IDemoFight } from "./IDemoFight.sol";
import { DemoFightInternal } from "./DemoFightInternal.sol";

contract DemoFightFacet is IDemoFight, DemoFightInternal {

  function battleWonBy(address user, uint256 reward) public {
    _battleWonBy(user, reward);
  }

  function claimReward(address user) public {
    _claimReward(user);
  }

//External getters

  function getTotalYield() external view returns(uint256) {
    return _totalYield();
  }

  function getCurrentYield() external view returns(uint256) {
    return _currentYield();
  }

  function getLockedYield() external view returns(uint256) {
    return _lockedYield();
  }

  function getStakedByKnights() external view returns(uint256) {
    return _stakedByKnights();
  }

  function getUserReward(address user) external view returns(uint256) {
    return _userReward(user);
  }

  function getYieldInfo()
    external
    view
    returns(uint256, uint256, uint256, uint256)
  {
    return(
      _currentYield(),
      _totalYield(),
      _lockedYield(),
      _stakedByKnights()
    );
  }
}
