// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.0;

import { ISBVHook } from "../../shared/interfaces/ISBVHook.sol";

contract SBVHookFacetDummy is ISBVHook {

  function SBV_hook(uint id, address newOwner, bool mint) external {}

  event VillageInfoUpdated(uint id, address newOwner, uint villageAmount);
}