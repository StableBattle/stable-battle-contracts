// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.0;

import { ISBVHook } from "../../shared/interfaces/ISBVHook.sol";
import { MetaStorage as META } from "../storage/MetaStorage.sol";

contract SBVHookFacet is ISBVHook {
  using META for META.Layout;

  modifier onlySBV {
    require(address(META.layout().SBV) == msg.sender,
      "SBVHookFacet: can only be called by SBV");
    _;
  }

  function SBV_hook(uint id, address newOwner, bool mint) external onlySBV {
    META.layout().villageOwner[id] = newOwner;
    if (mint == true) { META.layout().villageAmount++; }
    emit VillageInfoUpdated(id, newOwner, META.layout().villageAmount);
  }

  event VillageInfoUpdated(uint id, address newOwner, uint villageAmount);
}