// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.0;

import { gearSlot } from "../../Meta/DataStructures.sol";

import { IGear } from "../Gear/IGear.sol";
import { GearInternal } from "../Gear/GearInternal.sol";
import { GearModifiers } from "../Gear/GearModifiers.sol";
import { ItemsModifiers } from "../Items/ItemsModifiers.sol";

contract GearFacet is IGear, GearModifiers, GearInternal {

  //Add a transfer hook to unequip sold or lended item
  //Or forbid selling equipped items
  //Preferably the former

  function createGear(uint id, gearSlot slot, string memory name)
    external
  {
    _createGear(id, slot, name);
  }

  function updateKnightGear(uint256 knightId, uint256[] memory items)
    external
    ifOwnsItem(knightId)
  {
    _updateKnightGear(knightId, items);
  }

  function mintGear(uint id, uint amount, address to)
    external
  {
    _mintGear(id, amount, to);
  }

  function mintGear(uint id, uint amount)
    external
  {
    _mintGear(id, amount);
  }

  function burnGear(uint id, uint amount, address from)
    external 
  {
    _burnGear(id, amount, from);
  }

  function burnGear(uint id, uint amount)
    external
  {
    _burnGear(id, amount);
  }

//Public Getters

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