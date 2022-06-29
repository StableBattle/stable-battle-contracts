// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.0;

interface ISBVHook {

  function SBV_hook(uint id, address newOwner, bool mint) external;

}