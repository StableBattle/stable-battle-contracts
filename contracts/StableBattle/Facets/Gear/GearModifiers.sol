// SPDX-License-Identifier: Unlicensed

pragma solidity ^0.8.0;

import { GearStorage } from "../Gear/GearStorage.sol";

abstract contract GearModifiers {
  using GearStorage for GearStorage.State;

  function isGear(uint256 id) internal view returns(bool) {
    return id >= GearStorage.state().gearRangeLeft && 
           id <  GearStorage.state().gearRangeRight;
  }
  
  modifier ifIsGear(uint256 id) {
    require(isGear(id), "GearModifiers: Wrong id range for gear item");
    _;
  }
}