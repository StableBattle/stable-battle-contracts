// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.0;

import "../../shared/interfaces/ISBVHook.sol";
import { MetaStorage as Ms } from "../storage/MetaStorage.sol";

contract SBVHookFacet is ISBVHook {
  using Ms for Ms.Layout;

  modifier onlySBV {
    require(address(Ms.layout().SBV) == msg.sender,
      "SBVHookFacet: can only be called by SBV");
    _;
  }

  function SBV_hook(uint id, address newOwner, bool mint) external onlySBV {
    Ms.layout().villageOwner[id] = newOwner;
    if (mint == true) { Ms.layout().villageAmount++; }
    emit VillageInfoUpdated(id, newOwner, Ms.layout().villageAmount);
  }

  event VillageInfoUpdated(uint id, address newOwner, uint villageAmount);
}