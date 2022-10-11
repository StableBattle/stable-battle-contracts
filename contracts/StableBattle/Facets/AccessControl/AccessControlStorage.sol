// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.0;

import { Role } from "../../Meta/DataStructures.sol";

library AccessControlStorage {
  struct State {
    mapping (address => Role) role;
  }

  bytes32 internal constant STORAGE_SLOT = keccak256("AccessControl.storage");

  function state() internal pure returns (State storage l) {
    bytes32 slot = STORAGE_SLOT;
    assembly {
      l.slot := slot
    }
  }
}