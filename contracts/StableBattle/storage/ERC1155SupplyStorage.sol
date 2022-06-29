// SPDX-License-Identifier: Unlicensed

pragma solidity ^0.8.0;

library ERC1155SupplyStorage {
  struct Layout {
    // Total amount of tokens in with a given id.
    mapping(uint256 => uint256) _totalSupply;
  }

  bytes32 internal constant STORAGE_SLOT = keccak256("ERC1155Supply.storage");

  function layout() internal pure returns (Layout storage l) {
    bytes32 slot = STORAGE_SLOT;
    assembly {
      l.slot := slot
    }
  }
}
