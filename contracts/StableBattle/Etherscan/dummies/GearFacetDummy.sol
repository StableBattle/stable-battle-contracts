// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.0;

import { gearSlot } from "../../Gear/GearStorage.sol";

contract GearFacetDummy {

//Gear Facet
  function createGear(uint id, gearSlot slot, string memory name) external {}

  function updateKnightGear(uint256 knightId, uint256[] memory items) external {}

  function mintGear(uint id, uint amount, address to) external {}

  function mintGear(uint id, uint amount) external {}

  function burnGear(uint id, uint amount, address from) external {}

  function burnGear(uint id, uint amount) external {}

//Gear Getters
  function getGearSlotOf(uint256 itemId) external view returns(gearSlot) {}

  function getGearName(uint256 itemId) external view returns(string memory) {}

  function getEquipmentInSlot(uint256 knightId, gearSlot slot) external view returns(uint256) {}

  function getGearEquipable(address account, uint256 itemId) external view returns(uint256) {}

  function getGearEquipable(uint256 itemId) external view returns(uint256) {}

  event GearCreated(uint256 id, gearSlot slot, string name);
  event GearEquipped(uint256 knightId, gearSlot slot, uint256 itemId);
}