// SPDX-License-Identifier: Unlicensed

pragma solidity ^0.8.0;

import { Pool, Coin } from "./MetaStorage.sol";

struct Knight {
  Pool pool;
  Coin coin;
  address owner;
  uint256 inClan;
}

library KnightStorage {
  struct State {
    mapping(uint256 => Knight) knight;
    mapping(Coin => uint256) knightPrice;
    mapping(Pool => mapping(Coin => uint256)) knightsMinted;
    mapping(Pool => mapping(Coin => uint256)) knightsBurned;
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
  function knightInfo(uint256 knightId) internal view virtual returns(Knight memory) {
    return KnightStorage.state().knight[knightId];
  }

  function knightCoin(uint256 knightId) internal view virtual returns(Coin) {
    return KnightStorage.state().knight[knightId].coin;
  }

  function knightPool(uint256 knightId) internal view virtual returns(Pool) {
    return KnightStorage.state().knight[knightId].pool;
  }

  function knightOwner(uint256 knightId) internal view virtual returns(address) {
    return KnightStorage.state().knight[knightId].owner;
  }

  function knightClan(uint256 knightId) internal view virtual returns(uint256) {
    return KnightStorage.state().knight[knightId].inClan;
  }

  function knightPrice(Coin coin) internal view virtual returns (uint256) {
    return KnightStorage.state().knightPrice[coin];
  }

  //returns amount of minted knights for a particular coin & pool
  function knightsMinted(Pool pool, Coin coin) internal view virtual returns (uint256) {
    return KnightStorage.state().knightsMinted[pool][coin];
  }

  //returns amount of minted knights for any coin in a particular pool
  function knightsMintedOfPool(Pool pool) internal view virtual returns (uint256 minted) {
    for (uint8 coin = 1; coin < uint8(type(Coin).max) + 1; coin++) {
      minted += knightsMinted(pool, Coin(coin));
    }
  }

  //returns amount of minted knights for any pool in a particular coin
  function knightsMintedOfCoin(Coin coin) internal view virtual returns (uint256 minted) {
    for (uint8 pool = 1; pool < uint8(type(Pool).max) + 1; pool++) {
      minted += knightsMinted(Pool(pool), coin);
    }
  }

  //returns a total amount of minted knights
  function knightsMintedTotal() internal view virtual returns (uint256 minted) {
    for (uint8 pool = 1; pool < uint8(type(Pool).max) + 1; pool++) {
      minted += knightsMintedOfPool(Pool(pool));
    }
  }

  //returns amount of burned knights for a particular coin & pool
  function knightsBurned(Pool pool, Coin coin) internal view virtual returns (uint256) {
    return KnightStorage.state().knightsBurned[pool][coin];
  }

  //returns amount of burned knights for any coin in a particular pool
  function knightsBurnedOfPool(Pool pool) internal view virtual returns (uint256 burned) {
    for (uint8 coin = 1; coin < uint8(type(Coin).max) + 1; coin++) {
      burned += knightsBurned(pool, Coin(coin));
    }
  }

  //returns amount of burned knights for any pool in a particular coin
  function knightsBurnedOfCoin(Coin coin) internal view virtual returns (uint256 burned) {
    for (uint8 pool = 1; pool < uint8(type(Pool).max) + 1; pool++) {
      burned += knightsBurned(Pool(pool), coin);
    }
  }

  //returns a total amount of burned knights
  function knightsBurnedTotal() internal view virtual returns (uint256 burned) {
    for (uint8 pool = 1; pool < uint8(type(Pool).max) + 1; pool++) {
      burned += knightsBurnedOfPool(Pool(pool));
    }
  }

  function totalKnightSupply() internal view virtual returns (uint256) {
    return knightsMintedTotal() - knightsBurnedTotal();
  }
}

abstract contract KnightModifiers is KnightGetters {
  function isKnight(uint256 knightId) internal view virtual returns(bool) {
    return knightId >= type(uint256).max - knightsMintedTotal();
  }
  
  modifier ifIsKnight(uint256 knightId) {
    require(isKnight(knightId),
      "KnightModifiers: Wrong id for knight");
    _;
  }

  function isInAnyClan(uint256 knightId) internal view virtual returns(bool) {
    return knightClan(knightId) != 0;
  }

  modifier ifIsInAnyClan(uint256 knightId) {
    require(isInAnyClan(knightId),
      "KnightModifiers: This knight don't belong to any clan");
    _;
  }

  function isInClan(uint256 knightId, uint256 clanId) internal view virtual returns(bool) {
    return knightClan(knightId) == clanId;
  }

  modifier ifIsInClan(uint256 knightId, uint256 clanId) {
    require(isInClan(knightId, clanId),
      "KnightModifiers: This knight don't belong to this clan");
    _;
  }

  function notInClan(uint256 knightId) internal view virtual returns(bool) {
    return knightClan(knightId) == 0;
  }

  modifier ifNotInClan(uint256 knightId) {
    require(notInClan(knightId),
      "KnightModifiers: This knight already belongs to some clan");
    _;
  }
}
