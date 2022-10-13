// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.0;

interface IAccessControlEvents {
  event AdminAdded(address newAdmin);
  event AdminRemoved(address oldAdmin);
}