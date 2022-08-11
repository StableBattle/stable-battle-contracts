// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.0;

interface ISBTInternal {
  event Stake(address sender, uint clanId, uint256 amount);
  event Withdraw(address sender, uint clanId, uint256 amount);
}