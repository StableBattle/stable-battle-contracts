// SPDX-License-Identifier: Unlicensed

pragma solidity ^0.8.0;

import { Coin, Pool, Knight } from "../../Meta/DataStructures.sol";

import { IKnightGetters } from "../Knight/IKnight.sol";

import { KnightStorage } from "../Knight/KnightStorage.sol";
import { SetupAddressLib } from "../../Init&Updates/SetupAddressLib.sol";

abstract contract KnightGettersExternal is IKnightGetters {
  function getKnightInfo(uint256 knightId) external view returns(Knight memory) {
    return Knight(
      KnightStorage.layout().knightPool[knightId], 
      KnightStorage.layout().knightCoin[knightId], 
      KnightStorage.layout().knightOwner[knightId], 
      KnightStorage.layout().knightClan[knightId]
    );
  }

  function getKnightCoin(uint256 knightId) external view returns(Coin) {
    return KnightStorage.layout().knightCoin[knightId];
  }

  function getKnightPool(uint256 knightId) external view returns(Pool) {
    return KnightStorage.layout().knightPool[knightId];
  }

  function getKnightOwner(uint256 knightId) external view returns(address) {
    return KnightStorage.layout().knightOwner[knightId];
  }

  function getKnightClan(uint256 knightId) external view returns(uint256) {
    return KnightStorage.layout().knightClan[knightId];
  }

  function getKnightPrice(Coin coin) external view returns (uint256) {
    return KnightStorage.layout().knightPrice[coin];
  }

  //returns amount of minted knights for a particular coin & pool
  function getKnightsMinted(Pool pool, Coin coin) external view returns (uint256) {
    return KnightStorage.knightsMinted(pool, coin);
  }

  //returns amount of minted knights for any coin in a particular pool
  function getKnightsMintedOfPool(Pool pool) external view returns (uint256 knightsMintedTotal) {
    return KnightStorage.knightsMintedOfPool(pool);
  }

  //returns amount of minted knights for any pool in a particular coin
  function getKnightsMintedOfCoin(Coin coin) external view returns (uint256) {
    return KnightStorage.knightsMintedOfCoin(coin);
  }

  //returns a total amount of minted knights
  function getKnightsMintedTotal() external view returns (uint256) {
    return KnightStorage.knightsMintedTotal();
  }

  //returns amount of burned knights for a particular coin & pool
  function getKnightsBurned(Pool pool, Coin coin) external view returns (uint256) {
    return KnightStorage.knightsBurned(pool, coin);
  }

  //returns amount of burned knights for any coin in a particular pool
  function getKnightsBurnedOfPool(Pool pool) external view returns (uint256 knightsBurnedTotal) {
    return KnightStorage.knightsBurnedOfPool(pool);
  }

  //returns amount of burned knights for any pool in a particular coin
  function getKnightsBurnedOfCoin(Coin coin) external view returns (uint256) {
    return KnightStorage.knightsBurnedOfCoin(coin);
  }

  //returns a total amount of burned knights
  function getKnightsBurnedTotal() external view returns (uint256) {
    return KnightStorage.knightsBurnedTotal();
  }

  function getTotalKnightSupply() external view returns (uint256) {
    return KnightStorage.totalKnightSupply();
  }

  function getPoolAndCoinCompatibility(Pool p, Coin c) external pure returns (bool) {
    return SetupAddressLib.isCompatible(p, c);
  }
}