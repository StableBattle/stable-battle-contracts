// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.0;

import { IGear } from "../../shared/interfaces/IGear.sol";

import { GearStorage as GEAR, gearSlot, GearModifiers, GearGetters } from "../storage/GearStorage.sol";
import { ItemsGetters, ItemsModifiers } from "../storage/ItemsStorage.sol";
import { KnightModifiers } from "../storage/KnightStorage.sol";

contract GearFacet is IGear, GearGetters, KnightModifiers, GearModifiers, ItemsGetters, ItemsModifiers {
  using GEAR for GEAR.State;

  //Add a transfer hook to unequip sold or lended item
  //Or forbid selling equipped items
  //Preferably the former

  function createGear(uint id, gearSlot slot, string memory name) public isGear(id) {
    require(gearSlotOf(id) == gearSlot.NONE,
      "ForgeFacet: This type of gear already exists, use mintGear instead");
    require(slot != gearSlot.NONE,
      "ForgeFacet: Can't create gear of type NONE");

    GEAR.state().gearSlot[id] = slot;
    GEAR.state().gearName[id] = name;
    emit GearCreated(id, slot, name);
  }

  function equipItem(uint256 knightId, uint256 itemId)
    internal
    isGear(itemId)
    ifOwnsItem(itemId)
  {
    uint256 oldItemId = equipmentInSlot(knightId, gearSlotOf(itemId));
    if (oldItemId != itemId) {
      require(getGearEquipable(msg.sender, itemId) > 0,
        "GearFacet: This item is not equipable (either equipped on other character or part of ongoing lending or sell order)");
      //Equip new gear
      GEAR.state().knightSlotItem[knightId][gearSlotOf(itemId)] = itemId;
      GEAR.state().notEquippable[msg.sender][itemId]++;
      //Unequip old gear
      if (oldItemId != 0) {
        GEAR.state().notEquippable[msg.sender][oldItemId]--;
      }
      emit GearEquipped(knightId, gearSlotOf(itemId), itemId);
    }
  }

  function unequipItem(uint256 knightId, gearSlot slot) internal {
    uint256 oldItemId = equipmentInSlot(knightId, slot);
    //Uneqip slot
    GEAR.state().knightSlotItem[knightId][slot] = 0;
    //Unequip item
    if (oldItemId != 0) {
      GEAR.state().notEquippable[msg.sender][oldItemId]--;
    }
  }

  function updateKnightGear(uint256 knightId, uint256[] memory items)
    public
    ifIsKnight(knightId)
    ifOwnsItem(knightId)
  {
    for (uint i = 0; i < items.length; i++) {
      if (items[i] > type(uint8).max) {
        equipItem(knightId, items[i]);
      } else {
        unequipItem(knightId, gearSlot(uint8(items[i])));
      }
    }
  }

  function getGearEquipable(address account, uint256 itemId)
    public
    view
    isGear(itemId)
    returns(uint256)
  { return _balanceOf(account, itemId) - notEquippable(account, itemId); }

  function getGearEquipable(uint256 itemId)
    public
    view
    isGear(itemId)
    returns(uint256)
  { return _balanceOf(msg.sender, itemId) - notEquippable(msg.sender, itemId); }

//Public Getters

  function getGearSlotOf(uint256 itemId) public view returns(gearSlot) {
    return gearSlotOf(itemId);
  }

  function getGearName(uint256 itemId) public view returns(string memory) {
    return gearName(itemId);
  }

  function getEquipmentInSlot(uint256 knightId, gearSlot slot) public view returns(uint256) {
    return equipmentInSlot(knightId, slot);
  }
}