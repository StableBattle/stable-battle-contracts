// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.0;

import { ItemsFacet } from "./ItemsFacet.sol";
import { IForge } from "../../shared/interfaces/IForge.sol";

import { GearStorage as GEAR, gearSlot } from "../storage/GearStorage.sol";
import { ItemsStorage as ITEM } from "../storage/ItemsStorage.sol";
import { KnightStorage as KNHT } from "../storage/KnightStorage.sol";

contract ForgeFacet is ItemsFacet, IForge {
  using GEAR for GEAR.Layout;
  using ITEM for ITEM.Layout;
  using KNHT for KNHT.Layout;

  function createGear(uint id, gearSlot slot, string memory name) public isGear(id) {
    require(GEAR.layout().gearSlot[id] == gearSlot.EMPTY,
      "ForgeFacet: This type of gear already exists, use mintGear instead");
    GEAR.layout().gearSlot[id] = slot;
    GEAR.layout().gearName[id] = name;
  }

  function mintGear(uint id, uint amount, address to) public isGear(id) {
    require(GEAR.layout().gearSlot[id] != gearSlot.EMPTY,
      "ForgeFacet: This type of gear not yet exists, use createGear instead");
    _mint(to, id, amount, "");
  }

  function mintGear(uint id, uint amount) public {
    mintGear(id, amount, msg.sender);
  }

  function burnGear(uint id, uint amount, address from) public isGear(id) {
    require(balanceOf(from, id) >= amount,
      "ForgeFacet: Insufficient amount of gear items to burn");
    _burn(from, id, amount);
  }

  function burnGear(uint id, uint amount) public {
    burnGear(id, amount, msg.sender);
  }

  modifier isGear(uint256 id) {
    require(id >= GEAR.layout().gearRangeLeft && 
            id <  GEAR.layout().gearRangeRight,
            "ForgeFacet: Wrong id range for gear item");
    _;
  }
}