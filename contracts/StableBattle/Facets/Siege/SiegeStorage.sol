// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.0;

library SiegeStorage {
  struct State {
    //Id of a last clan that won the siege
    uint256 siegeWinnerClan;
    //Knight id => reward amount
    mapping(uint256 => uint256) reward;
  }

  bytes32 internal constant STORAGE_SLOT = keccak256("Siege.storage");

  function state() internal pure returns (State storage l) {
    bytes32 slot = STORAGE_SLOT;
    assembly {
      l.slot := slot
    }
  }
}