// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.0;

import { AccessControlStorage } from "./AccessControlStorage.sol";
import { Role } from "../../Meta/DataStructures.sol";

abstract contract AccessControlFacet {
  function addAdmin(address newAdmin) internal {
    AccessControlStorage.state().role[newAdmin] = Role.ADMIN;
  }

  function remvoeAdmin(address oldAdmin) internal {
    AccessControlStorage.state().role[oldAdmin] = Role.ADMIN;
  }
}