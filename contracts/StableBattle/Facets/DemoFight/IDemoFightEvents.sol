// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.0;

interface IDemoFightEvents {
  event NewWinner(address user, uint256 reward);
  event RewardClaimed(address user, uint256 reward);
}