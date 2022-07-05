// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.0;

import { ITreasury } from "../../shared/interfaces/ITreasury.sol";

interface ITreasury {

  function claimRewards() external;

  function getRewardPerBlock() external view returns(uint);

  function getTax() external view returns(uint);

  function setTax(uint tax) external;

  event BeneficiaryUpdated (uint village, address beneficiary);
  event NewTaxSet(uint tax);
}