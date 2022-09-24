// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.0;

import { ISBVHook } from "../StableBattle/Facets/SBVHook/ISBVHook.sol";
import { SBVStorage } from "./SBVStorage.sol";

contract SBVGetters {
  using SBVStorage for SBVStorage.State;

  function SBVHook() internal view returns(ISBVHook) {
    return ISBVHook(SBVStorage.state().SBD);
  }
}