// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.0;

import { IGear } from "../../shared/interfaces/IGear.sol";

import { GearStorage as GEAR, gearSlot } from "../storage/GearStorage.sol";
import { ItemsStorage as ITEM } from "../storage/ItemsStorage.sol";
import { KnightStorage as KNHT } from "../storage/KnightStorage.sol";

contract GearFacet is IGear {
  using GEAR for GEAR.Layout;
  using ITEM for ITEM.Layout;
  using KNHT for KNHT.Layout;

  function getGearSlot(uint256 itemId) public view notKnight(itemId) returns(gearSlot) {
    return GEAR.layout().gearSlot[itemId];
  }

  function getGearName(uint256 itemId) public view notKnight(itemId) returns(string memory) {
    return GEAR.layout().gearName[itemId];
  }

  function getGearEquipable(address account, uint256 itemId) public view notKnight(itemId) returns(uint256) {
    uint256 itemBalance = noCallBalanceOf(account, itemId);
    uint256 equippedOrLended = GEAR.layout().notEquippable[account][itemId];
    return itemBalance - equippedOrLended;
  }

  function getEquipmentInSlot(uint256 knightId, gearSlot slot) public view returns(uint256) {
    return GEAR.layout().knightSlotItem[knightId][slot];
  }

  function createGear(uint id, gearSlot slot, string memory name) public isGear(id) {
    require(GEAR.layout().gearSlot[id] == gearSlot.EMPTY,
      "ForgeFacet: This type of gear already exists, use mintGear instead");
    require(slot != gearSlot.EMPTY,
      "ForgeFacet: Can't create gear of type EMPTY");
    GEAR.layout().gearSlot[id] = slot;
    GEAR.layout().gearName[id] = name;
    emit GearCreated(id, slot, name);
  }

  function equipItem(uint256 knightId, uint256 itemId) private notKnight(itemId) {
    require(noCallBalanceOf(msg.sender, itemId) > 0, 
      "GearFacet: You don't own this item");
    uint256 oldItemId = getEquipmentInSlot(knightId, getGearSlot(itemId));
    if (oldItemId != itemId) {
      require(getGearEquipable(msg.sender, itemId) > 0,
        "GearFacet: This item is not equipable (either equipped on other character or part of ongoing lending or sell order)");
      //Equip new gear
      GEAR.layout().knightSlotItem[knightId][getGearSlot(itemId)] = itemId;
      GEAR.layout().notEquippable[msg.sender][itemId]++;
      //Unequip old gear
      if (oldItemId != 0) {
        GEAR.layout().notEquippable[msg.sender][oldItemId]--;
      }
      emit GearEquipped(knightId, getGearSlot(itemId), itemId);
    }
  }

  function unequipItem(uint256 knightId, gearSlot slot) private {
    uint256 oldItemId = getEquipmentInSlot(knightId, slot);
    //Uneqip slot
    GEAR.layout().knightSlotItem[knightId][slot] = 0;
    //Unequip item
    if (oldItemId != 0) {
      GEAR.layout().notEquippable[msg.sender][oldItemId]--;
    }
  }

  function updateKnightGear(uint256 knightId, uint256[] memory items) external isKnight(knightId) {
    require(noCallBalanceOf(msg.sender, knightId)> 0, 
      "GearFacet: You don't own this knight");
    for (uint i = 0; i < items.length; i++) {
      if (items[i] > type(uint8).max) {
        equipItem(knightId, items[i]);
      } else {
        unequipItem(knightId, gearSlot(uint8(items[i])));
      }
    }
  }

  function noCallBalanceOf(address account, uint256 id) private view returns (uint256) {
    require(account != address(0), "ERC1155: address zero is not a valid owner");
    return ITEM.layout()._balances[id][account];
  }

  modifier notKnight(uint256 itemId) {
    require(itemId < KNHT.layout().knightOffset, 
      "GearFacet: Knight is not an equipment");
    _;
  }

  modifier isKnight(uint256 knightId) {
    require(knightId >= KNHT.layout().knightOffset, 
      "GearFacet: Equipment is not a knight");
    _;
  }

  modifier isGear(uint256 id) {
    require(id >= GEAR.layout().gearRangeLeft && 
            id <  GEAR.layout().gearRangeRight,
            "GearFacet: Wrong id range for gear item");
    _;
  }
}