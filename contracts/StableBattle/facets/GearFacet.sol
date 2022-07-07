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

  function getGearEquipable(uint256 itemId, address account) public view notKnight(itemId) returns(uint256) {
    require(account != address(0), "ERC1155: address zero is not a valid owner");
    uint256 balance = ITEM.layout()._balances[itemId][account];
    uint256 equippedOrLended = GEAR.layout().notEquippable[account][itemId];
    return balance - equippedOrLended;
  }

  function getEquipmentInSlot(uint256 knightId, gearSlot slot) public view returns(uint256) {
    return GEAR.layout().knightSlotItem[knightId][slot];
  } 

  function equipItem(uint256 knightId, uint256 itemId) private notKnight(itemId) isKnight(knightId) {
    require(ITEM.layout()._balances[itemId][msg.sender] > 0, 
      "GearFacet: You don't own this item");
    require(getGearEquipable(itemId, msg.sender) > 0,
      "GearFacet: This item is not equipable (either equipped on other character or part of ongoing lending or sell order)");
    GEAR.layout().knightSlotItem[knightId][getGearSlot(itemId)] = itemId;
    GEAR.layout().notEquippable[msg.sender][itemId]--;
    emit GearEquipped(knightId, getGearSlot(itemId), itemId);
  }

  function updateKnightGear(uint256 knightId, uint256[] memory items) external isKnight(knightId) {
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

  modifier isKnight(uint256 knightId) {
    require(knightId >= KNHT.layout().knightOffset, 
      "GearFacet: Equipment is not a knight");
    _;
  }
}