// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.0;

import { IGear } from "../../shared/interfaces/IGear.sol";

import { GearStorage as GEAR, gearSlot, Gear } from "../storage/GearStorage.sol";
import { ItemsStorage as ITEM } from "../storage/ItemsStorage.sol";
import { KnightStorage as KNHT } from "../storage/KnightStorage.sol";

contract GearFacet is IGear {
  using GEAR for GEAR.Layout;
  using ITEM for ITEM.Layout;
  using KNHT for KNHT.Layout;

  function getGearSlot(uint256 itemId) public view notKnight(itemId) returns(gearSlot) {
    return GEAR.layout().gear[itemId].slot;
  }

  function getGearEquipable(uint256 itemId) public view notKnight(itemId) returns(bool) {
    return GEAR.layout().gear[itemId].equipable;
  }

  function getEquipmentInSlot(uint256 knightId, gearSlot slot) public view returns(uint256) {
    return GEAR.layout().knightSlotItem[knightId][slot]; 
  } 

  function equipItem(uint256 knightId, uint256 itemId) private {
    require(ITEM.layout()._balances[itemId][msg.sender] > 0, 
      "GearFacet: You don't own this item");
    require(getGearEquipable(itemId),
      "GearFacet: This item is not equipable (either part of ongoing lending or trade order)");
    GEAR.layout().knightSlotItem[knightId][getGearSlot(itemId)] = itemId;
    emit GearEquipped(knightId, getGearSlot(itemId), itemId);
  }

  function updateGear(uint256 knightId, uint256[] memory items) external {
    require(knightId >= KNHT.layout().knightOffset, 
      "GearFacet: Item being equipped is not a knight");
    require(ITEM.layout()._balances[knightId][msg.sender] > 0, 
      "GearFacet: You don't own this knight");
    for (uint i = 0; i < items.length; i++) {
      equipItem(knightId, items[i]);
    }
  }

  modifier notKnight(uint256 itemId) {
    require(itemId < KNHT.layout().knightOffset, 
      "GearFacet: Knight is not an equipment");
    _;
  }
}