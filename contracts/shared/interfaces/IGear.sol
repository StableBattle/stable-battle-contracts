// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.0;

import { gearSlot } from "../../StableBattle/storage/GearStorage.sol";

interface IGear {

//Gear Facet
  function createGear(uint id, gearSlot slot, string memory name) external;

  function updateKnightGear(uint256 knightId, uint256[] memory items) external;

//Gear Getters
  function getGearEquipable(address account, uint256 itemId) external view returns(uint256);

  function getGearSlotOf(uint256 itemId) external view returns(gearSlot);

  function getGearName(uint256 itemId) external view returns(string memory);

  function getEquipmentInSlot(uint256 knightId, gearSlot slot) external view returns(uint256);

  event GearCreated(uint256 id, gearSlot slot, string name);
  event GearEquipped(uint256 knightId, gearSlot slot, uint256 itemId);
}