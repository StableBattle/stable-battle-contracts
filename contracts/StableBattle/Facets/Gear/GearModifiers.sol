// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.0;

import { GearStorage } from "../Gear/GearStorage.sol";
import { IGearErrors } from "../Gear/IGear.sol";

abstract contract GearModifiers is IGearErrors {
  function isGear(uint256 id) internal view returns(bool) {
    return id >= GearStorage.layout().gearRangeLeft && 
           id <  GearStorage.layout().gearRangeRight;
  }
  
  modifier ifIsGear(uint256 id) {
    if(!isGear(id)) {
      revert GearModifiers_WrongGearId(id);
    }
    _;
  }
}