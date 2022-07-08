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
  
  function knightCheck(uint256 kinghtId) internal view returns(Knight memory) {
    return layout().knight[kinghtId];
  }

  function knightClan(uint256 kinghtId) internal view returns(uint256) {
    return layout().knight[kinghtId].inClan;
  }

  function knightClanOwnerOf(uint256 kinghtId) internal view returns(uint256) {
    return layout().knight[kinghtId].ownsClan;
  }

  function knightLevel(uint256 kinghtId) internal view returns(uint) {
    return layout().knight[kinghtId].level;
  }

  function knightTypeOf(uint256 kinghtId) internal view returns(knightType) {
    return layout().knight[kinghtId].kt;
  }

  function knightOwner(uint256 knightId) internal view returns(address) {
    return layout().knight[knightId].owner;
  }

  function knightOffset() internal view returns (uint256) {
    return layout().knightOffset;
  }
}

contract KnightModifiers {
  modifier notKnight(uint256 itemId) {
    require(itemId < KnightStorage.layout().knightOffset, 
      "GearFacet: Knight is not an equipment");
    _;
  }

  modifier isKnight(uint256 knightId) {
    require(knightId >= KnightStorage.layout().knightOffset, 
      "GearFacet: Equipment is not a knight");
    _;
  }
}
