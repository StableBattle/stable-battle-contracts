// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.0;

import { ITreasury } from "../../shared/interfaces/ITreasury.sol";

contract TreasuryFacetDummy is ITreasury {

  function claimRewards() public {}

  function getRewardPerBlock() public view returns(uint) {}

  function getTax() public view returns(uint) {}

  function setTax(uint tax) external {}
}