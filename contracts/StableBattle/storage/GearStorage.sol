// SPDX-License-Identifier: Unlicensed

pragma solidity ^0.8.0;

enum gearSlot {
  WEAPON,
  SHIELD,
  HELMET,
  ARMOR,
  PANTS,
  SLEEVES,
  GLOVES,
  BOOTS,
  JEWELRY,
  CLOAK
}

struct Gear {
  gearSlot slot;
  bool equipable;
}

library GearStorage {
	struct Layout {
    //knightId => gearSlot => itemId
    mapping(uint256 => mapping(gearSlot => uint256)) knightSlotItem;
    //itemId => Gear
    mapping(uint256 => Gear) gear;
	}

	bytes32 internal constant STORAGE_SLOT = keccak256("Gear.storage");

	function layout() internal pure returns (Layout storage l) {
		bytes32 slot = STORAGE_SLOT;
		assembly {
			l.slot := slot
		}
	}
}
