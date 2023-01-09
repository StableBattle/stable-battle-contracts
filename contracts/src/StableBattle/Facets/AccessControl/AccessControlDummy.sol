// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.0;

import { IAccessControl } from "./IAccessControl.sol";

contract AccessControlDummy is IAccessControl {
  function addAdmin(address newAdmin) external {}

  function removeAdmin(address oldAdmin) external {}
}