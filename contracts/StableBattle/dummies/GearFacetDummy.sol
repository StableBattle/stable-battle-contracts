// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.0;

import { IGear } from "../../shared/interfaces/IGear.sol";

import { gearSlot } from "../storage/GearStorage.sol";

contract GearFacetDummy is IGear {

  function getGearSlot(uint256 itemId) public view returns(gearSlot) {}

  function getGearName(uint256 itemId) public view returns(string memory) {}

  function getGearEquipable(uint256 itemId, address account) public view returns(uint256) {}

  function getEquipmentInSlot(uint256 knightId, gearSlot slot) public view returns(uint256) {}

  function updateKnightGear(uint256 knightId, uint256[] memory items) external {}
}