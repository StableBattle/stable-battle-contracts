// SPDX-License-Identifier: Unlicensed

pragma solidity ^0.8.0;

import { TreasuryStorage } from "../Treasury/TreasuryStorage.sol";
import { ITreasuryGetters } from "../Treasury/ITreasury.sol";

abstract contract TreasuryGettersExternal is ITreasuryGetters {
  function getCastleTax() public view returns(uint) {
    return TreasuryStorage.layout().castleTax;
  }

  function getLastBlock() public view returns(uint) {
    return TreasuryStorage.layout().lastBlock;
  }

  function getRewardPerBlock() public view returns(uint) {
    return TreasuryStorage.layout().rewardPerBlock;
  }

  function getVillageAmount() internal view virtual returns(uint256) {
    return TreasuryStorage.layout().villageAmount;
  }

  function getVillageOwner(uint256 villageId) internal view virtual returns(address) {
    return TreasuryStorage.layout().villageOwner[villageId];
  }
}