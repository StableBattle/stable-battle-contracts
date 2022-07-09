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
  struct State {
    uint256 knightOffset;
    mapping(uint256 => Knight) knight;
    mapping(knightType => uint256) knightPrice;
  }

  bytes32 internal constant STORAGE_SLOT = keccak256("Knight.storage");

  function state() internal pure returns (State storage l) {
    bytes32 slot = STORAGE_SLOT;
    assembly {
      l.slot := slot
    }
  }
  
  function knightCheck(uint256 kinghtId) internal view returns(Knight memory) {
    return state().knight[kinghtId];
  }

  function knightClan(uint256 kinghtId) internal view returns(uint256) {
    return state().knight[kinghtId].inClan;
  }

  function knightClanOwnerOf(uint256 kinghtId) internal view returns(uint256) {
    return state().knight[kinghtId].ownsClan;
  }

  function knightLevel(uint256 kinghtId) internal view returns(uint) {
    return state().knight[kinghtId].level;
  }

  function knightTypeOf(uint256 kinghtId) internal view returns(knightType) {
    return state().knight[kinghtId].kt;
  }

  function knightOwner(uint256 knightId) internal view returns(address) {
    return state().knight[knightId].owner;
  }

  function knightOffset() internal view returns (uint256) {
    return state().knightOffset;
  }

  function knightPrice(knightType kt) internal view returns (uint256) {
    return state().knightPrice[kt];
  }
}

contract KnightModifiers {
  modifier notKnight(uint256 itemId) {
    require(itemId < KnightStorage.state().knightOffset, 
      "KnightModifiers: Wrong id for something other than knight");
    _;
  }

  modifier isKnight(uint256 knightId) {
    require(knightId >= KnightStorage.state().knightOffset, 
      "KnightModifiers: Wrong id for knight");
    _;
  }
}
