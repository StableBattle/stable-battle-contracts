// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.0;

import { ISBVHook } from "../../shared/interfaces/ISBVHook.sol";
import { MetaStorage as META } from "../storage/MetaStorage.sol";

contract SBVHookFacet is ISBVHook {
  using META for META.State;

  function SBV_hook(uint id, address newOwner, bool mint) external onlySBV {
    META.state().villageOwner[id] = newOwner;
    if (mint == true) { META.state().villageAmount++; }
    emit VillageInfoUpdated(id, newOwner, META.villageAmount());
  }

  modifier onlySBV {
    require(address(META.SBV()) == msg.sender,
      "SBVHookFacet: can only be called by SBV");
    _;
  }
}