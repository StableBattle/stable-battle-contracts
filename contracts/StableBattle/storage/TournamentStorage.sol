// SPDX-License-Identifier: Unlicensed

pragma solidity ^0.8.0;

library TournamentStorage {
  struct State {
    //clan that holds the castle
    uint256 castleHolderClan;
  }

  bytes32 internal constant STORAGE_SLOT = keccak256("Tournament.storage");

  function state() internal pure returns (State storage l) {
    bytes32 slot = STORAGE_SLOT;
    assembly {
      l.slot := slot
    }
  }
}

abstract contract TournamentGetters {
  function castleHolderClan() internal view virtual returns (uint256) {
    return TournamentStorage.state().castleHolderClan;
  }
}
