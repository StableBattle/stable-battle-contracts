// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.0;

import { IAccessControlErrors } from "./IAccessControlErrors.sol";
import { IAccessControlEvents } from "./IAccessControlEvents.sol";

interface IAccessControl is IAccessControlErrors, IAccessControlEvents {
  function addAdmin(address newAdmin) external;

  function removeAdmin(address oldAdmin) external;
}