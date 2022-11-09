// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.0;

import { IAccessControl } from "./IAccessControl.sol";
import { AccessControlInternal } from "./AccessControlInternal.sol";
import { AccessControlModifiers } from "./AccessControlModifiers.sol";

contract AccessControlFacet is IAccessControl, AccessControlInternal, AccessControlModifiers {
  function addAdmin(address newAdmin) external ifCallerIsAdmin {
    _addAdmin(newAdmin);
  }

  function removeAdmin(address oldAdmin) external ifCallerIsAdmin {
    _removeAdmin(oldAdmin);
  }
}