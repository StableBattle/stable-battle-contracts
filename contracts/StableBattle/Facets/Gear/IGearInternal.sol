// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.0;

import { gearSlot } from "../Gear/GearStorage.sol";

interface IGearInternal {
  event GearCreated(uint256 id, gearSlot slot, string name);
  event GearMinted(uint256 id, uint256 amount, address to);
  event GearBurned(uint256 id, uint256 amount, address from);
  event GearEquipped(uint256 knightId, gearSlot slot, uint256 itemId);
}