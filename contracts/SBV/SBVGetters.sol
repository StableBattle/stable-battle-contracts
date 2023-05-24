// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.0;

import { ISBVHook } from "../StableBattle/Facets/SBVHook/ISBVHook.sol";
import { DiamondAddressLib } from "../StableBattle/Init&Updates/DiamondAddressLib.sol";

contract SBVGetters {
  function SBVHook() internal pure returns(ISBVHook) {
    return ISBVHook(DiamondAddressLib.DiamondAddress);
  }
}