// SPDX-License-Identifier: Unlicensed

pragma solidity ^0.8.0;

library ItemsStorage {
	struct Layout {
		// Mapping from token ID to its owner
		mapping (uint256 => address) _knightOwners;
	}

	bytes32 internal constant STORAGE_SLOT = keccak256("Items.storage");

	function layout() internal pure returns (Layout storage l) {
		bytes32 slot = STORAGE_SLOT;
		assembly {
			l.slot := slot
		}
	}
}
