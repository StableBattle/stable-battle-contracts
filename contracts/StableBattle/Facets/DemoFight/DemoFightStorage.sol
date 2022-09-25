// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.0;

import { Pool, Coin } from "../../Meta/DataStructures.sol";

library DemoFightStorage {
  struct State {
    mapping (address => mapping (Pool => mapping (Coin => uint256))) userReward;
    mapping (Pool => mapping (Coin => uint256)) lockedYield;
  }

  bytes32 internal constant STORAGE_SLOT = keccak256("DemoFight.storage");

  function state() internal pure returns (State storage l) {
    bytes32 slot = STORAGE_SLOT;
    assembly {
      l.slot := slot
    }
  }
}