// SPDX-License-Identifier: Unlicensed

pragma solidity ^0.8.0;

library TreasuryStorage {
  struct Layout {
    uint castleTax;
    address[] beneficiaries;
    uint lastBlock;
    uint rewardPerBlock;
  }

  bytes32 internal constant STORAGE_SLOT = keccak256("Treasury.storage");

  function layout() internal pure returns (Layout storage l) {
    bytes32 slot = STORAGE_SLOT;
    assembly {
      l.slot := slot
    }
  }
}
