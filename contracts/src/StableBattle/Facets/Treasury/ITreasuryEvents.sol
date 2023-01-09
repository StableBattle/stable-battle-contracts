// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.0;

interface ITreasuryEvents {
  event BeneficiaryUpdated(uint village, address beneficiary);
  event NewTaxSet(uint tax);
}