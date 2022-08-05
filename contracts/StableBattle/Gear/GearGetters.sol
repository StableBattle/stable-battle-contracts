// SPDX-License-Identifier: Unlicensed

pragma solidity ^0.8.0;

import { GearStorage, gearSlot } from "../Gear/GearStorage.sol";
import { ERC1155BaseInternal } from "@solidstate/contracts/token/ERC1155/base/ERC1155BaseInternal.sol";

abstract contract GearGetters is ERC1155BaseInternal {
  using GearStorage for GearStorage.State;
  
  function _gearSlotOf(uint256 itemId) internal view virtual returns(gearSlot) {
    return GearStorage.state().gearSlot[itemId];
  }

  function _gearName(uint256 itemId) internal view virtual returns(string memory) {
    return GearStorage.state().gearName[itemId];
  }

  function _equipmentInSlot(uint256 knightId, gearSlot slot) internal view virtual returns(uint256) {
    return GearStorage.state().knightSlotItem[knightId][slot];
  }

  function _notEquippable(address account, uint256 itemId) internal view virtual returns(uint256) {
    return GearStorage.state().notEquippable[account][itemId];
  }

  function _gearEquipable(address account, uint256 itemId) internal view returns(uint256) { 
    return _balanceOf(account, itemId) - _notEquippable(account, itemId);
  }

  function _gearEquipable(uint256 itemId) internal view returns(uint256) { 
    return _balanceOf(msg.sender, itemId) - _notEquippable(msg.sender, itemId);
  }
}