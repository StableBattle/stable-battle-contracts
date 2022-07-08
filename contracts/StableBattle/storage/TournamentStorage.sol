// SPDX-License-Identifier: Unlicensed

pragma solidity ^0.8.0;

library TournamentStorage {
  struct Layout {
    //clan that holds the castle
    uint256 castleHolder;
  }

  bytes32 internal constant STORAGE_SLOT = keccak256("Tournament.storage");

  function layout() internal pure returns (Layout storage l) {
    bytes32 slot = STORAGE_SLOT;
    assembly {
      l.slot := slot
    }
  }

  function castleHolder() internal view returns (uint256) {
    return layout().castleHolder;
  }
}
