// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.0;

import { Coin, Pool, Knight } from "../../Meta/DataStructures.sol";
import { IKnight } from "./IKnight.sol";

contract KnightFacetDummy is IKnight {

//Knight Facet
  function mintKnight(Pool p, Coin c) external returns(uint256) {}

  function burnKnight (uint256 knightId, uint256 heirId) external {}

//Knight Getters
  function getKnightInfo(uint256 knightId) external view returns(Knight memory) {}

  function getKnightPool(uint256 knightId) external view returns(Pool) {}

  function getKnightCoin(uint256 knightId) external view returns(Coin) {}

  function getKnightOwner(uint256 knightId) external view returns(address) {}

  function getKnightClan(uint256 knightId) external view returns(uint256) {}

  function getKnightPrice(Coin coin) external view returns (uint256) {}

  //returns amount of minted knights for a particular coin & pool
  function getKnightsMinted(Pool pool, Coin coin) external view returns (uint256) {}

  //returns amount of minted knights for any coin in a particular pool
  function getKnightsMintedOfPool(Pool pool) external view returns (uint256 knightsMintedTotal) {}

  //returns amount of minted knights for any pool in a particular coin
  function getKnightsMintedOfCoin(Coin coin) external view returns (uint256) {}

  //returns a total amount of minted knights
  function getKnightsMintedTotal() external view returns (uint256) {}

  //returns amount of burned knights for a particular coin & pool
  function getKnightsBurned(Pool pool, Coin coin) external view returns (uint256) {}

  //returns amount of burned knights for any coin in a particular pool
  function getKnightsBurnedOfPool(Pool pool) external view returns (uint256 knightsBurnedTotal) {}

  //returns amount of burned knights for any pool in a particular coin
  function getKnightsBurnedOfCoin(Coin coin) external view returns (uint256) {}

  //returns a total amount of burned knights
  function getKnightsBurnedTotal() external view returns (uint256) {}

  function getTotalKnightSupply() external view returns (uint256) {}

  function getPoolAndCoinCompatibility(Pool p, Coin c) external view returns (bool) {}
}
