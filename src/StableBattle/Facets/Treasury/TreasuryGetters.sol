// SPDX-License-Identifier: Unlicensed

pragma solidity ^0.8.0;

import { TreasuryStorage } from "../Treasury/TreasuryStorage.sol";
import { ITreasuryGetters } from "../Treasury/ITreasury.sol";

abstract contract TreasuryGetters {
  function _castleTax() internal view virtual returns(uint) {
    return TreasuryStorage.state().castleTax;
  }

  function _lastBlock() internal view virtual returns(uint) {
    return TreasuryStorage.state().lastBlock;
  }

  function _rewardPerBlock() internal view virtual returns(uint) {
    return TreasuryStorage.state().rewardPerBlock;
  }

  function _villageAmount() internal view virtual returns(uint256) {
    return TreasuryStorage.state().villageAmount;
  }

  function _villageOwner(uint256 villageId) internal view virtual returns(address) {
    return TreasuryStorage.state().villageOwner[villageId];
  }
}

abstract contract TreasuryGettersExternal is ITreasuryGetters, TreasuryGetters {
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