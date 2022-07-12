// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.0;

import { ItemsFacet } from "./ItemsFacet.sol";
import { IForge } from "../../shared/interfaces/IForge.sol";

import { gearSlot, GearModifiers, GearGetters } from "../storage/GearStorage.sol";

contract ForgeFacet is ItemsFacet, IForge, GearModifiers, GearGetters {

  function mintGear(uint id, uint amount, address to) public isGear(id) {
    require(gearSlotOf(id) != gearSlot.NONE,
      "ForgeFacet: This type of gear not yet exists, use createGear instead");
    _mint(to, id, amount, "");
    emit GearMinted(id, amount, to);
  }

  function mintGear(uint id, uint amount) external {
    mintGear(id, amount, msg.sender);
  }

  function burnGear(uint id, uint amount, address from) public isGear(id) {
    require(balanceOf(from, id) >= amount,
      "ForgeFacet: Insufficient amount of gear items to burn");
    _burn(from, id, amount);
    emit GearBurned(id, amount, from);
  }

  function burnGear(uint id, uint amount) external {
    burnGear(id, amount, msg.sender);
  }
}