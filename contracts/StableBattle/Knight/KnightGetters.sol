// SPDX-License-Identifier: Unlicensed

pragma solidity ^0.8.0;

import { Knight, KnightStorage } from "../Knight/KnightStorage.sol";
import { Pool, Coin } from "../Meta/MetaStorage.sol";

abstract contract KnightGetters {
  using KnightStorage for KnightStorage.State;

  function _knightInfo(uint256 knightId) internal view virtual returns(Knight memory) {
    return KnightStorage.state().knight[knightId];
  }

  function _knightCoin(uint256 knightId) internal view virtual returns(Coin) {
    return KnightStorage.state().knight[knightId].coin;
  }

  function _knightPool(uint256 knightId) internal view virtual returns(Pool) {
    return KnightStorage.state().knight[knightId].pool;
  }

  function _knightOwner(uint256 knightId) internal view virtual returns(address) {
    return KnightStorage.state().knight[knightId].owner;
  }

  function _knightClan(uint256 knightId) internal view virtual returns(uint256) {
    return KnightStorage.state().knight[knightId].inClan;
  }

  function _knightPrice(Coin coin) internal view virtual returns (uint256) {
    return KnightStorage.state().knightPrice[coin];
  }

  //returns amount of minted knights for a particular coin & pool
  function _knightsMinted(Pool pool, Coin coin) internal view virtual returns (uint256) {
    return KnightStorage.state().knightsMinted[pool][coin];
  }

  //returns amount of minted knights for any coin in a particular pool
  function _knightsMintedOfPool(Pool pool) internal view virtual returns (uint256 minted) {
    for (uint8 coin = 1; coin < uint8(type(Coin).max) + 1; coin++) {
      minted += _knightsMinted(pool, Coin(coin));
    }
  }

  //returns amount of minted knights for any pool in a particular coin
  function _knightsMintedOfCoin(Coin coin) internal view virtual returns (uint256 minted) {
    for (uint8 pool = 1; pool < uint8(type(Pool).max) + 1; pool++) {
      minted += _knightsMinted(Pool(pool), coin);
    }
  }

  //returns a total amount of minted knights
  function _knightsMintedTotal() internal view virtual returns (uint256 minted) {
    for (uint8 pool = 1; pool < uint8(type(Pool).max) + 1; pool++) {
      minted += _knightsMintedOfPool(Pool(pool));
    }
  }

  //returns amount of burned knights for a particular coin & pool
  function _knightsBurned(Pool pool, Coin coin) internal view virtual returns (uint256) {
    return KnightStorage.state().knightsBurned[pool][coin];
  }

  //returns amount of burned knights for any coin in a particular pool
  function _knightsBurnedOfPool(Pool pool) internal view virtual returns (uint256 burned) {
    for (uint8 coin = 1; coin < uint8(type(Coin).max) + 1; coin++) {
      burned += _knightsBurned(pool, Coin(coin));
    }
  }

  //returns amount of burned knights for any pool in a particular coin
  function _knightsBurnedOfCoin(Coin coin) internal view virtual returns (uint256 burned) {
    for (uint8 pool = 1; pool < uint8(type(Pool).max) + 1; pool++) {
      burned += _knightsBurned(Pool(pool), coin);
    }
  }

  //returns a total amount of burned knights
  function _knightsBurnedTotal() internal view virtual returns (uint256 burned) {
    for (uint8 pool = 1; pool < uint8(type(Pool).max) + 1; pool++) {
      burned += _knightsBurnedOfPool(Pool(pool));
    }
  }

  function _totalKnightSupply() internal view virtual returns (uint256) {
    return _knightsMintedTotal() - _knightsBurnedTotal();
  }
}