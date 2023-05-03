// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.0;

interface ITreasuryEvents {
  event BeneficiaryUpdated(uint village, address beneficiary);
  event NewTaxSet(uint tax);
}

interface ITreasuryErrors {
  error TreasuryModifiers_OnlyCallableByCastleHolder();
  error TreasuryFacet_CantSetTaxAboveThreshold(uint8 threshold);
}

interface ITreasuryGetters {
  function getCastleTax() external view returns(uint);
  function getLastBlock() external view returns(uint);
  function getRewardPerBlock() external view returns(uint);
}

interface ITreasury is ITreasuryEvents, ITreasuryErrors, ITreasuryGetters {
  function claimRewards() external;
  function setTax(uint8 tax) external;
}