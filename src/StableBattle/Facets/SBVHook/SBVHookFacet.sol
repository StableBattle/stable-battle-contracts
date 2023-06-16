// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.0;

import { ISBVHook } from "../SBVHook/ISBVHook.sol";
import { MetaModifiers } from "../../Meta/MetaModifiers.sol";
import { TreasuryStorage } from "../Treasury/TreasuryStorage.sol";

contract SBVHookFacet is ISBVHook, MetaModifiers {
  function SBV_hook(uint id, address newOwner, bool mint) external ifIsSBV {
    TreasuryStorage.layout().villageOwner[id] = newOwner;
    if (mint == true) { TreasuryStorage.layout().villageAmount++; }
    emit VillageInfoUpdated(id, newOwner, TreasuryStorage.layout().villageAmount);
  }
}