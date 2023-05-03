// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.0;

import { gearSlot } from "../../Meta/DataStructures.sol";

import { IGearEvents } from "../Gear/IGear.sol";
import { GearStorage } from "../Gear/GearStorage.sol";
import { GearGetters } from "../Gear/GearGetters.sol";
import { GearModifiers } from "../Gear/GearModifiers.sol";
import { ItemsModifiers } from "../Items/ItemsModifiers.sol";
import { KnightModifiers } from "../Knight/KnightModifiers.sol";
import { ERC1155BaseInternal } from "solidstate-solidity/token/ERC1155/base/ERC1155BaseInternal.sol";

contract GearInternal is 
  IGearEvents,
  ERC1155BaseInternal,
  GearGetters,
  GearModifiers,
  KnightModifiers,
  ItemsModifiers
{
  //Add a transfer hook to unequip sold or lended item
  //Or forbid selling equipped items
  //Preferably the former

  function _createGear(uint id, gearSlot slot, string memory name) 
    internal 
    ifIsGear(id)
  {
    require(_gearSlotOf(id) == gearSlot.NONE,
      "ForgeFacet: This type of gear already exists, use mintGear instead");
    require(slot != gearSlot.NONE,
      "ForgeFacet: Can't create gear of type NONE");

    GearStorage.state().gearSlot[id] = slot;
    GearStorage.state().gearName[id] = name;
    emit GearCreated(id, slot, name);
  }

  function _equipItem(uint256 knightId, uint256 itemId)
    internal
    ifIsGear(itemId)
  {
    uint256 oldItemId = _equipmentInSlot(knightId, _gearSlotOf(itemId));
    if (oldItemId != itemId) {
      require(_gearEquipable(msg.sender, itemId) > 0,
        "GearFacet: This item is not equipable (either equipped on other character or part of ongoing lending or sell order)");
      //Equip new gear
      GearStorage.state().knightSlotItem[knightId][_gearSlotOf(itemId)] = itemId;
      GearStorage.state().notEquippable[msg.sender][itemId]++;
      //Unequip old gear
      if (oldItemId != 0) {
        GearStorage.state().notEquippable[msg.sender][oldItemId]--;
      }
      emit GearEquipped(knightId, _gearSlotOf(itemId), itemId);
    }
  }

  function _unequipItem(uint256 knightId, gearSlot slot) internal {
    uint256 oldItemId = _equipmentInSlot(knightId, slot);
    //Uneqip slot
    GearStorage.state().knightSlotItem[knightId][slot] = 0;
    //Unequip item
    if (oldItemId != 0) {
      GearStorage.state().notEquippable[msg.sender][oldItemId]--;
    }
  }

  function _updateKnightGear(uint256 knightId, uint256[] memory items)
    internal
    ifIsKnight(knightId)
    ifOwnsItem(knightId)
  {
    for (uint i = 0; i < items.length; i++) {
      if (items[i] > type(uint8).max) {
        require(ownsItem(items[i]), 
          "GearFacet: this piece of gear doesn't belong to you");
        _equipItem(knightId, items[i]);
      } else {
        _unequipItem(knightId, gearSlot(uint8(items[i])));
      }
    }
  }

  function _mintGear(uint id, uint amount, address to) internal ifIsGear(id) {
    require(_gearSlotOf(id) != gearSlot.NONE,
      "ForgeFacet: This type of gear not yet exists, use createGear instead");
    _mint(to, id, amount, "");
    emit GearMinted(id, amount, to);
  }

  function _mintGear(uint id, uint amount) internal {
    _mintGear(id, amount, msg.sender);
  }

  function _burnGear(uint id, uint amount, address from) internal ifIsGear(id) {
    require(_balanceOf(from, id) >= amount,
      "ForgeFacet: Insufficient amount of gear items to burn");
    _burn(from, id, amount);
    emit GearBurned(id, amount, from);
  }

  function _burnGear(uint id, uint amount) internal {
    _burnGear(id, amount, msg.sender);
  }
}