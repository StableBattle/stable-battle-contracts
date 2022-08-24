// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.10;

import { IKnight } from "../Knight/IKnight.sol";

import { Knight } from "../Knight/KnightStorage.sol";
import { KnightInternal } from "../Knight/KnightInternal.sol";
import { Pool, Coin } from "../Meta/MetaStorage.sol";
import { ItemsModifiers } from "../Items/ItemsModifiers.sol";

contract KnightFacet is IKnight,
                        ItemsModifiers,
                        KnightInternal
{
  function mintKnight(Pool p, Coin c)
    external
  {
    _mintKnight(p, c);
  }

  function burnKnight(uint256 knightId)
    external
  //ifOwnsItem(knightId)
  {
    _burnKnight(knightId);
  }

//Public Getters

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
    return isCompatible(p, c);
  }
}