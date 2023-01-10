// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.10;

import { ITreasury } from "../Treasury/ITreasury.sol";
import { TreasuryModifiers } from "../Treasury/TreasuryModifiers.sol";
import { TreasuryGetters, TreasuryGettersExternal } from "../Treasury/TreasuryGetters.sol";
import { TreasuryInternal } from "../Treasury/TreasuryInternal.sol";

contract TreasuryFacet is 
  ITreasury,
  TreasuryModifiers,
  TreasuryGetters,
  TreasuryGettersExternal,
  TreasuryInternal
{
  function claimRewards() external {
    _claimRewards();
  }

  function setTax(uint8 tax) external ifIsFromAddress(_castleHolderAddress()) {
    _setTax(tax);
  }
}