// SPDX-License-Identifier: Unlicensed

pragma solidity ^0.8.0;

import { IGearGetters } from "../Gear/IGear.sol";
import { gearSlot } from "../../Meta/DataStructures.sol";
import { GearStorage } from "../Gear/GearStorage.sol";
import { ERC1155BaseInternal } from "solidstate-solidity/token/ERC1155/base/ERC1155BaseInternal.sol";

abstract contract GearGetters is ERC1155BaseInternal {
  function _gearSlotOf(uint256 itemId) internal view virtual returns(gearSlot) {
    return GearStorage.layout().gearSlot[itemId];
  }

  function _gearName(uint256 itemId) internal view virtual returns(string memory) {
    return GearStorage.layout().gearName[itemId];
  }

  function _equipmentInSlot(uint256 knightId, gearSlot slot) internal view virtual returns(uint256) {
    return GearStorage.layout().knightSlotItem[knightId][slot];
  }

  function _notEquippable(address account, uint256 itemId) internal view virtual returns(uint256) {
    return GearStorage.layout().notEquippable[account][itemId];
  }

  function _gearEquipable(address account, uint256 itemId) internal view returns(uint256) { 
    return _balanceOf(account, itemId) - _notEquippable(account, itemId);
  }

  function _gearEquipable(uint256 itemId) internal view returns(uint256) { 
    return _balanceOf(msg.sender, itemId) - _notEquippable(msg.sender, itemId);
  }
}

abstract contract GearGettersExternal is IGearGetters, GearGetters {
  function getGearSlotOf(uint256 itemId) external view returns(gearSlot) {
    return _gearSlotOf(itemId);
  }

  function getGearName(uint256 itemId) external view returns(string memory) {
    return _gearName(itemId);
  }

  function getEquipmentInSlot(uint256 knightId, gearSlot slot) external view returns(uint256) {
    return _equipmentInSlot(knightId, slot);
  }

  function getGearEquipable(address account, uint256 itemId) external view returns(uint256) {
    return _gearEquipable(account, itemId);
  }

  function getGearEquipable(uint256 itemId) external view returns(uint256) { 
    return _gearEquipable(itemId); 
  }
}