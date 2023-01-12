// SPDX-License-Identifier: Unlicensed

pragma solidity ^0.8.0;

import { Coin, Pool, Knight } from "../../Meta/DataStructures.sol";

import { IKnightGetters } from "../Knight/IKnight.sol";

import { KnightStorage } from "../Knight/KnightStorage.sol";
import { MetaStorage } from "../../Meta/MetaStorage.sol";


abstract contract KnightGetters {
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

  function _knightClanActivityCooldown(uint256 knightId) internal view returns(uint256) {
    return KnightStorage.state().clanActivityCooldown[knightId];
  }
}

abstract contract KnightGettersExternal is IKnightGetters, KnightGetters {
  function getKnightInfo(uint256 knightId) external view returns(Knight memory) {
    return _knightInfo(knightId);
  }

  function getKnightCoin(uint256 knightId) external view returns(Coin) {
    return _knightCoin(knightId);
  }

  function getKnightPool(uint256 knightId) external view returns(Pool) {
    return _knightPool(knightId);
  }

  function getKnightOwner(uint256 knightId) external view returns(address) {
    return _knightOwner(knightId);
  }

  function getKnightClan(uint256 knightId) external view returns(uint256) {
    return _knightClan(knightId);
  }

  function getKnightPrice(Coin coin) external view returns (uint256) {
    return _knightPrice(coin);
  }

  //returns amount of minted knights for a particular coin & pool
  function getKnightsMinted(Pool pool, Coin coin) external view returns (uint256) {
    return _knightsMinted(pool, coin);
  }

  //returns amount of minted knights for any coin in a particular pool
  function getKnightsMintedOfPool(Pool pool) external view returns (uint256 knightsMintedTotal) {
    return _knightsMintedOfPool(pool);
  }

  //returns amount of minted knights for any pool in a particular coin
  function getKnightsMintedOfCoin(Coin coin) external view returns (uint256) {
    return _knightsMintedOfCoin(coin);
  }

  //returns a total amount of minted knights
  function getKnightsMintedTotal() external view returns (uint256) {
    return _knightsMintedTotal();
  }

  //returns amount of burned knights for a particular coin & pool
  function getKnightsBurned(Pool pool, Coin coin) external view returns (uint256) {
    return _knightsBurned(pool, coin);
  }

  //returns amount of burned knights for any coin in a particular pool
  function getKnightsBurnedOfPool(Pool pool) external view returns (uint256 knightsBurnedTotal) {
    return _knightsBurnedOfPool(pool);
  }

  //returns amount of burned knights for any pool in a particular coin
  function getKnightsBurnedOfCoin(Coin coin) external view returns (uint256) {
    return _knightsBurnedOfCoin(coin);
  }

  //returns a total amount of burned knights
  function getKnightsBurnedTotal() external view returns (uint256) {
    return _knightsBurnedTotal();
  }

  function getTotalKnightSupply() external view returns (uint256) {
    return _totalKnightSupply();
  }

  function getPoolAndCoinCompatibility(Pool p, Coin c) external view returns (bool) {
    return MetaStorage.state().compatible[p][c];
  }

  function getKnightClanActivityCooldown(uint256 knightId) external view returns(uint256) {
    return KnightStorage.state().clanActivityCooldown[knightId];
  }
}