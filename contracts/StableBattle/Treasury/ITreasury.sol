// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.0;

import { ITreasuryInternal } from "../Treasury/ITreasuryInternal.sol";

interface ITreasury is ITreasuryInternal {

//Treasury Facet

  function claimRewards() external;

  function setTax(uint8 tax) external;

//Public Getters

  function getCastleTax() external view returns(uint);
  
  function getLastBlock() external view returns(uint);

  function getRewardPerBlock() external view returns(uint);
}