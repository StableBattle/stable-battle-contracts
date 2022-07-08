// SPDX-License-Identifier: Unlicensed

pragma solidity ^0.8.0;

enum gearSlot {
  NONE,
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

library GearStorage {
  struct Layout {
    uint256 gearRangeLeft;
    uint256 gearRangeRight;
    //knightId => gearSlot => itemId
    //Returns an itemId of item equipped in gearSlot for Knight with knightId
    mapping(uint256 => mapping(gearSlot => uint256)) knightSlotItem;
    //itemId => slot
    //Returns gear slot for particular item per itemId
    mapping(uint256 => gearSlot) gearSlot;
    //itemId => itemName
    //Returns a name of particular item per itemId
    mapping(uint256 => string) gearName;
    //knightId => itemId => amount 
    //Returns amount of nonequippable (either already equipped or lended or in pending sell order)
      //items per itemId for a particular wallet
    mapping(address => mapping(uint256 => uint256)) notEquippable;
  }

  bytes32 internal constant STORAGE_SLOT = keccak256("Gear.storage");

  function layout() internal pure returns (Layout storage l) {
    bytes32 slot = STORAGE_SLOT;
    assembly {
      l.slot := slot
    }
  }

  function getGearSlot(uint256 itemId) internal view returns(gearSlot) {
    return layout().gearSlot[itemId];
  }

  function getGearName(uint256 itemId) internal view returns(string memory) {
    return layout().gearName[itemId];
  }

  function getEquipmentInSlot(uint256 knightId, gearSlot slot) internal view returns(uint256) {
    return layout().knightSlotItem[knightId][slot];
  }

  function notEquippable(address account, uint256 itemId) internal view returns(uint256) {
    return layout().notEquippable[account][itemId];
  }
}

contract GearModifiers {
  modifier isGear(uint256 id) {
    require(id >= GearStorage.layout().gearRangeLeft && 
            id <  GearStorage.layout().gearRangeRight,
            "GearFacet: Wrong id range for gear item");
    _;
  }
}
