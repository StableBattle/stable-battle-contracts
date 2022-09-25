// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.0;

interface ITreasuryErrors {
  error TreasuryModifiers_OnlyCallableByCastleHolder();
  error TreasuryFacet_CantSetTaxAboveThreshold(uint8 threshold);
}