// SPDX-License-Identifier: Unlicensed

pragma solidity ^0.8.0;

enum knightType {
  NONE,
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
    mapping(uint256 => Knight) knight;
    mapping(knightType => uint256) knightPrice;
    mapping(knightType => uint256) knightsMinted;
    mapping(knightType => uint256) knightsBurned;
  }

  bytes32 internal constant STORAGE_SLOT = keccak256("Knight.storage");

  function state() internal pure returns (State storage l) {
    bytes32 slot = STORAGE_SLOT;
    assembly {
      l.slot := slot
    }
  }
}

abstract contract KnightGetters {
  function knightCheck(uint256 knightId) internal view virtual returns(Knight memory) {
    return KnightStorage.state().knight[knightId];
  }

  function knightClan(uint256 knightId) internal view virtual returns(uint256) {
    return KnightStorage.state().knight[knightId].inClan;
  }

  function knightClanOwnerOf(uint256 knightId) internal view virtual returns(uint256) {
    return KnightStorage.state().knight[knightId].ownsClan;
  }

  function knightLevel(uint256 knightId) internal view virtual returns(uint) {
    return KnightStorage.state().knight[knightId].level;
  }

  function knightTypeOf(uint256 knightId) internal view virtual returns(knightType) {
    return KnightStorage.state().knight[knightId].kt;
  }

  function knightOwner(uint256 knightId) internal view virtual returns(address) {
    return KnightStorage.state().knight[knightId].owner;
  }

  function knightPrice(knightType kt) internal view virtual returns (uint256) {
    return KnightStorage.state().knightPrice[kt];
  }

  function knightsMinted(knightType kt) internal view virtual returns (uint256) {
    return KnightStorage.state().knightsMinted[kt];
  }

  function knightsBurned(knightType kt) internal view virtual returns (uint256) {
    return KnightStorage.state().knightsBurned[kt];
  }

  function totalKnightSupply(knightType kt) internal view virtual returns (uint256) {
    return knightsMinted(kt) - knightsBurned(kt);
  }

  function knightsMinted() internal view virtual returns (uint256 knightsMintedTotal) {
    for (uint8 i = 0; i < uint8(type(knightType).max) + 1; i++) {
      knightsMintedTotal += knightsMinted(knightType(i));
    }
  }

  function knightsBurned() internal view virtual returns (uint256 knightsBurnedTotal) {
    for (uint8 i = 0; i < uint8(type(knightType).max) + 1; i++) {
      knightsBurnedTotal += knightsBurned(knightType(i));
    }
  }

  function totalKnightSupply() internal view virtual returns (uint256) {
    return knightsMinted() - knightsBurned();
  }
}

abstract contract KnightModifiers is KnightGetters {
  function isKnight(uint256 knightId) internal view returns(bool) {
    return knightId >= type(uint256).max - knightsMinted();
  }
  
  modifier ifIsKnight(uint256 knightId) {
    require(isKnight(knightId),
      "KnightModifiers: Wrong id for knight");
    _;
  }
}
