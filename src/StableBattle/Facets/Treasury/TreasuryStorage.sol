// SPDX-License-Identifier: Unlicensed

pragma solidity ^0.8.0;

library TreasuryStorage {
  struct State {
    uint8 castleTax;
    uint lastBlock;
    uint rewardPerBlock;

    //Villages information
    uint256 villageAmount;
    mapping (uint256 => address) villageOwner;
  }

  bytes32 internal constant STORAGE_SLOT = keccak256("Treasury.storage");

  function state() internal pure returns (State storage l) {
    bytes32 slot = STORAGE_SLOT;
    assembly {
      l.slot := slot
    }
  }
}