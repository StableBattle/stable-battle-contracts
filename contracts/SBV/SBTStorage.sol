// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.0;

library SBVStorage {
  struct State {
    address SBD;
  }

  bytes32 internal constant STORAGE_SLOT = keccak256('SBV.storage');

  function state() internal pure returns (State storage l) {
    bytes32 slot = STORAGE_SLOT;
    assembly {
      l.slot := slot
    }
  }
}