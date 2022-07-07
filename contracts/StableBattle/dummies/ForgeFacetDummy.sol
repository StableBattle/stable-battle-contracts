// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.0;

import { IForge } from "../../shared/interfaces/IForge.sol";
import { ItemsFacetDummy } from "./ItemsFacetDummy.sol";
import { gearSlot } from "../../StableBattle/storage/GearStorage.sol";

contract ForgeFacetDummy is IForge, ItemsFacetDummy {
  function mintGear(uint id, uint amount, address to) public {}

  function mintGear(uint id, uint amount) public {}

  function burnGear(uint id, uint amount, address from) public {}

  function burnGear(uint id, uint amount) public {}
}