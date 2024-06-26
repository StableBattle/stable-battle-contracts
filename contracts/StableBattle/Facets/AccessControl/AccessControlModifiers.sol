// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.0;

import { AccessControlStorage } from "./AccessControlStorage.sol";
import { Role } from "../../Meta/DataStructures.sol";
import { IAccessControlErrors } from "./IAccessControl.sol";

abstract contract AccessControlModifiers is IAccessControlErrors {
  function callerIsAdmin() internal view returns(bool) {
    return AccessControlStorage.layout().role[msg.sender] == Role.ADMIN;
  }

  modifier ifCallerIsAdmin() {
    if(!callerIsAdmin()) {
      //revert AccessControlModifiers_CallerIsNotAdmin(msg.sender);
      revert ("Access Control Modifiers: Caller Is Not Admin");
    }
    _;
  }
}