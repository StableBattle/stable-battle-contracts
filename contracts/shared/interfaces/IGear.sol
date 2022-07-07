// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.0;

import { gearSlot } from "../../StableBattle/storage/GearStorage.sol";

interface IGear {
  
  function getGearSlot(uint256 itemId) external returns(gearSlot);

  function getGearName(uint256 itemId) external view returns(string memory);

  function getGearEquipable(address account, uint256 itemId) external returns(uint256);

  function getEquipmentInSlot(uint256 knightId, gearSlot slot) external returns(uint256);

  function createGear(uint id, gearSlot slot, string memory name) external;

  function updateKnightGear(uint256 knightId, uint256[] memory items) external;

  event GearCreated(uint256 id, gearSlot slot, string name);
  event GearEquipped(uint256 knightId, gearSlot slot, uint256 itemId);
}