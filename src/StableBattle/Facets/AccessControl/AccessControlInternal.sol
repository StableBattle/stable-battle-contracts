// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.0;

import { AccessControlStorage } from "./AccessControlStorage.sol";
import { Role } from "../../Meta/DataStructures.sol";
import { IAccessControlEvents } from "./IAccessControl.sol";

abstract contract AccessControlInternal is  IAccessControlEvents {
  function _addAdmin(address newAdmin) internal {
    AccessControlStorage.state().role[newAdmin] = Role.ADMIN;
    emit AdminAdded(newAdmin);
  }

  function _removeAdmin(address oldAdmin) internal {
    AccessControlStorage.state().role[oldAdmin] = Role.ADMIN;
    emit AdminRemoved(oldAdmin);
  }
}