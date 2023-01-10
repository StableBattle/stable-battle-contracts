// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.0;

import { gearSlot } from "../../Meta/DataStructures.sol";

interface IGearEvents {
  event GearCreated(uint256 id, gearSlot slot, string name);
  event GearMinted(uint256 id, uint256 amount, address to);
  event GearBurned(uint256 id, uint256 amount, address from);
  event GearEquipped(uint256 knightId, gearSlot slot, uint256 itemId);
}

interface IGearErrors {
  error GearModifiers_WrongGearId(uint256 gearId);
}

interface IGearGetters {
  function getGearSlotOf(uint256 itemId) external view returns(gearSlot);

  function getGearName(uint256 itemId) external view returns(string memory);

  function getEquipmentInSlot(uint256 knightId, gearSlot slot) external view returns(uint256);

  function getGearEquipable(address account, uint256 itemId) external view returns(uint256);

  function getGearEquipable(uint256 itemId) external view returns(uint256);
}

interface IGear is IGearEvents, IGearErrors, IGearGetters {
  function createGear(uint id, gearSlot slot, string memory name) external;

  function updateKnightGear(uint256 knightId, uint256[] memory items) external;

  function mintGear(uint id, uint amount, address to) external;

  function mintGear(uint id, uint amount) external;

  function burnGear(uint id, uint amount, address from) external;

  function burnGear(uint id, uint amount) external;
}