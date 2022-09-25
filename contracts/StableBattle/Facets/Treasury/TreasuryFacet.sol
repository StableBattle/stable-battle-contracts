// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.10;

import { ITreasury } from "../Treasury/ITreasury.sol";
import { TreasuryModifiers } from "../Treasury/TreasuryModifiers.sol";
import { TreasuryGetters } from "../Treasury/TreasuryGetters.sol";
import { TreasuryInternal } from "../Treasury/TreasuryInternal.sol";

contract TreasuryFacet is ITreasury,
                          TreasuryModifiers,
                          TreasuryGetters,
                          TreasuryInternal
{
  function claimRewards() external {
    _claimRewards();
  }

  function setTax(uint8 tax) external ifIsFromAddress(_castleHolderAddress()) {
    _setTax(tax);
  }

//Public Getters
  function getCastleTax() public view returns(uint) {
    return _castleTax();
  }
  
  function getLastBlock() public view returns(uint) {
    return _lastBlock();
  }

  function getRewardPerBlock() public view returns(uint) {
    return _rewardPerBlock();
  }
}