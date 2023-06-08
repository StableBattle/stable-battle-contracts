// SPDX-License-Identifier: None

pragma solidity ^0.8.0;

library LzAppStorage {
  struct Layout {
    mapping(uint16 => bytes) trustedRemoteLookup;
    mapping(uint16 => mapping(uint16 => uint)) minDstGasLookup;
    mapping(uint16 => uint) payloadSizeLimitLookup;
    address precrime;
    mapping(uint16 => mapping(bytes => mapping(uint64 => bytes32))) failedMessages;
  }

  bytes32 internal constant STORAGE_SLOT = keccak256("BEER.OFT.lzApp.storage");

  function layout() internal pure returns (Layout storage l) {
    bytes32 slot = STORAGE_SLOT;
    assembly {
      l.slot := slot
    }
  }
}