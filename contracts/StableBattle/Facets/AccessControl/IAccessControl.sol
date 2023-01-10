// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.0;

interface IAccessControlEvents {
  event AdminAdded(address newAdmin);
  event AdminRemoved(address oldAdmin);
}

interface IAccessControlErrors {
  error AccessControlModifiers_CallerIsNotAdmin(address caller);
}

interface IAccessControl is IAccessControlEvents, IAccessControlErrors {
  function addAdmin(address newAdmin) external;

  function removeAdmin(address oldAdmin) external;
}