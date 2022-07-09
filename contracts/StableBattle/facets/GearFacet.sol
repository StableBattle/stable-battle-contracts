// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.0;

import { IGear } from "../../shared/interfaces/IGear.sol";

import { GearStorage as GEAR, gearSlot, GearModifiers } from "../storage/GearStorage.sol";
import { ItemsStorage as ITEM } from "../storage/ItemsStorage.sol";
import { KnightModifiers } from "../storage/KnightStorage.sol";

contract GearFacet is IGear, KnightModifiers, GearModifiers {
  using GEAR for GEAR.State;
  using ITEM for ITEM.State;

  function createGear(uint id, gearSlot slot, string memory name) public isGear(id) {
    require(GEAR.getGearSlot(id) == gearSlot.NONE,
      "ForgeFacet: This type of gear already exists, use mintGear instead");
    require(slot != gearSlot.NONE,
      "ForgeFacet: Can't create gear of type EMPTY");
    GEAR.state().gearSlot[id] = slot;
    GEAR.state().gearName[id] = name;
    emit GearCreated(id, slot, name);
  }

  function equipItem(uint256 knightId, uint256 itemId) private notKnight(itemId) {
    require(ITEM.balanceOf(msg.sender, itemId) > 0, 
      "GearFacet: You don't own this item");
    uint256 oldItemId = getEquipmentInSlot(knightId, getGearSlot(itemId));
    if (oldItemId != itemId) {
      require(getGearEquipable(msg.sender, itemId) > 0,
        "GearFacet: This item is not equipable (either equipped on other character or part of ongoing lending or sell order)");
      //Equip new gear
      GEAR.state().knightSlotItem[knightId][getGearSlot(itemId)] = itemId;
      GEAR.state().notEquippable[msg.sender][itemId]++;
      //Unequip old gear
      if (oldItemId != 0) {
        GEAR.state().notEquippable[msg.sender][oldItemId]--;
      }
      emit GearEquipped(knightId, getGearSlot(itemId), itemId);
    }
  }

  function unequipItem(uint256 knightId, gearSlot slot) private {
    uint256 oldItemId = getEquipmentInSlot(knightId, slot);
    //Uneqip slot
    GEAR.state().knightSlotItem[knightId][slot] = 0;
    //Unequip item
    if (oldItemId != 0) {
      GEAR.state().notEquippable[msg.sender][oldItemId]--;
    }
  }

  function updateKnightGear(uint256 knightId, uint256[] memory items) external isKnight(knightId) {
    require(ITEM.balanceOf(msg.sender, knightId)> 0, 
      "GearFacet: You don't own this knight");
    for (uint i = 0; i < items.length; i++) {
      if (items[i] > type(uint8).max) {
        equipItem(knightId, items[i]);
      } else {
        unequipItem(knightId, gearSlot(uint8(items[i])));
      }
    }
  }

  function getGearSlot(uint256 itemId) public view notKnight(itemId) returns(gearSlot) {
    return GEAR.getGearSlot(itemId);
  }

  function getGearName(uint256 itemId) public view notKnight(itemId) returns(string memory) {
    return GEAR.getGearName(itemId);
  }

  function getEquipmentInSlot(uint256 knightId, gearSlot slot) public view returns(uint256) {
    return GEAR.getEquipmentInSlot(knightId, slot);
  }

  function notEquippable(address account, uint256 itemId) internal view returns(uint256) {
    return GEAR.notEquippable(account, itemId);
  }

  function getGearEquipable(address account, uint256 itemId) public view notKnight(itemId) returns(uint256) {
    uint256 itemBalance = ITEM.balanceOf(account, itemId);
    uint256 equippedOrLended = notEquippable(account, itemId);
    return itemBalance - equippedOrLended;
  }
}