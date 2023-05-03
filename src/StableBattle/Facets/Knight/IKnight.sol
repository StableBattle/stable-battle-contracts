// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.0;

import { Coin, Pool, Knight } from "../../Meta/DataStructures.sol";

interface IKnightEvents {
  event KnightMinted (uint knightId, address wallet, Pool p, Coin c);
  event KnightBurned (uint knightId, address wallet, Pool p, Coin c);
}

interface IKnightErrors {
  error KnightFacet_InsufficientFunds(uint256 avalible, uint256 required);
  error KnightFacet_AbandonLeaderRoleBeforeBurning(uint256 knightId, uint256 clanId);
  error KnightFacet_CantAppointYourselfAsHeir(uint256 knightId);
  error KnightFacet_HeirIsNotKnight(uint256 heirId);
  error KnightFacet_HeirIsNotInTheSameClan(uint256 clanId, uint256 heirId);

  error KnightModifiers_WrongKnightId(uint256 wrongId);
  error KnightModifiers_KnightNotInAnyClan(uint256 knightId);
  error KnightModifiers_KnightNotInClan(uint256 knightId, uint256 wrongClanId, uint256 correctClanId);
  error KnightModifiers_KnightInSomeClan(uint256 knightId, uint256 clanId);
}

interface IKnightGetters {
  function getKnightInfo(uint256 knightId) external view returns(Knight memory);

  function getKnightPool(uint256 knightId) external view returns(Pool);

  function getKnightCoin(uint256 knightId) external view returns(Coin);

  function getKnightOwner(uint256 knightId) external view returns(address);

  function getKnightClan(uint256 knightId) external view returns(uint256);

  function getKnightPrice(Coin coin) external view returns (uint256);

  //returns amount of minted knights for a particular coin & pool
  function getKnightsMinted(Pool pool, Coin coin) external view returns (uint256);

  //returns amount of minted knights for any coin in a particular pool
  function getKnightsMintedOfPool(Pool pool) external view returns (uint256 knightsMintedTotal);

  //returns amount of minted knights for any pool in a particular coin
  function getKnightsMintedOfCoin(Coin coin) external view returns (uint256);

  //returns a total amount of minted knights
  function getKnightsMintedTotal() external view returns (uint256);

  //returns amount of burned knights for a particular coin & pool
  function getKnightsBurned(Pool pool, Coin coin) external view returns (uint256);

  //returns amount of burned knights for any coin in a particular pool
  function getKnightsBurnedOfPool(Pool pool) external view returns (uint256 knightsBurnedTotal);

  //returns amount of burned knights for any pool in a particular coin
  function getKnightsBurnedOfCoin(Coin coin) external view returns (uint256);

  //returns a total amount of burned knights
  function getKnightsBurnedTotal() external view returns (uint256);

  function getTotalKnightSupply() external view returns (uint256);

  function getPoolAndCoinCompatibility(Pool p, Coin c) external view returns (bool);
}

interface IKnight is IKnightEvents, IKnightErrors, IKnightGetters {
  function mintKnight(Pool p, Coin c) external returns(uint256);

  function burnKnight (uint256 knightId, uint256 heirId) external;
}
