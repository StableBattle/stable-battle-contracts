// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.0;

import { IAccessControl } from "./IAccessControl.sol";
import { AccessControlInternal } from "./AccessControlInternal.sol";

contract AccessControlFacet is IAccessControl, AccessControlInternal {
  function addAdmin(address newAdmin) external {
    _addAdmin(newAdmin);
  }

  function removeAdmin(address oldAdmin) external {
    _removeAdmin(oldAdmin);
  }
}