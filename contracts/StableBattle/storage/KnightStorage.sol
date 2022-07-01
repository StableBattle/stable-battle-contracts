// SPDX-License-Identifier: Unlicensed

pragma solidity ^0.8.0;

enum knightType {
  AAVE,
  OTHER
}

struct Knight {
  uint256 inClan;
  uint256 ownsClan;
  uint level;
  knightType kt;
	address owner;
}

library KnightStorage {

	struct Layout {
    uint256 knightOffset;
    mapping(uint256 => Knight) knight;
	}

	bytes32 internal constant STORAGE_SLOT = keccak256("Knight.storage");

	function layout() internal pure returns (Layout storage l) {
		bytes32 slot = STORAGE_SLOT;
		assembly {
			l.slot := slot
		}
	}
}
