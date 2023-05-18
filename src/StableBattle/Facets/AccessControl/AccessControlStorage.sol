// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.0;

import { Role, ClanRole } from "../../Meta/DataStructures.sol";

library AccessControlStorage {
  struct Layout {
    mapping (address => Role) role;
    //knightId => ClanRole
    mapping (uint256 => ClanRole) clanRole;
  }

  bytes32 internal constant STORAGE_SLOT = keccak256("AccessControl.storage");

  function layout() internal pure returns (Layout storage l) {
    bytes32 slot = STORAGE_SLOT;
    assembly {
      l.slot := slot
    }
  }
}