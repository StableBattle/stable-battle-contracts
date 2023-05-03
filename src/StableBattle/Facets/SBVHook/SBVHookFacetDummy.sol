// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.0;

import { ISBVHook } from "./ISBVHook.sol";

contract SBVHookFacetDummy is ISBVHook {
  function SBV_hook(uint id, address newOwner, bool mint) external {}
}