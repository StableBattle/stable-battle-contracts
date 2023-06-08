// SPDX-License-Identifier: Unlicensed

pragma solidity ^0.8.0;

library OFTStorage {
  struct Layout {
    bool useCustomAdapterParams;
  }

  bytes32 internal constant STORAGE_SLOT = keccak256("BEER.OFT.storage");

  function layout() internal pure returns (Layout storage l) {
    bytes32 slot = STORAGE_SLOT;
    assembly {
      l.slot := slot
    }
  }
}