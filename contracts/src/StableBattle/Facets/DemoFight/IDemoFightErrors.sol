// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.0;

interface IDemoFightErrors {
  error DemoFightFacet_RewardBiggerThanYield(uint256 reward, uint256 currentYield);
}