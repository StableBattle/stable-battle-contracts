// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.0;

import { ISBVHook } from "../../shared/interfaces/ISBVHook.sol";
import { MetaModifiers } from "../storage/MetaStorage.sol";
import { TreasuryStorage as TRSR, TreasuryGetters } from "../storage/TreasuryStorage.sol";

contract SBVHookFacet is ISBVHook, MetaModifiers, TreasuryGetters {
  using TRSR for TRSR.State;

  function SBV_hook(uint id, address newOwner, bool mint) external onlySBV {
    TRSR.state().villageOwner[id] = newOwner;
    if (mint == true) { TRSR.state().villageAmount++; }
    emit VillageInfoUpdated(id, newOwner, villageAmount());
  }
}