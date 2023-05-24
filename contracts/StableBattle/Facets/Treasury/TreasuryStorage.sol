// SPDX-License-Identifier: Unlicensed

pragma solidity ^0.8.0;

library TreasuryStorage {
  struct Layout {
    uint8 castleTax;
    uint lastBlock;
    uint rewardPerBlock;

    //Villages information
    uint256 villageAmount;
    mapping (uint256 => address) villageOwner;
  }

  bytes32 internal constant STORAGE_SLOT = keccak256("Treasury.storage");

  function layout() internal pure returns (Layout storage l) {
    bytes32 slot = STORAGE_SLOT;
    assembly {
      l.slot := slot
    }
  }
}