// SPDX-License-Identifier: Unlicensed

pragma solidity ^0.8.0;

import { KnightGetters } from "./KnightGetters.sol";

abstract contract KnightModifiers is KnightGetters {
  function isKnight(uint256 knightId) internal view virtual returns(bool) {
    return knightId >= type(uint256).max - _knightsMintedTotal();
  }
  
  modifier ifIsKnight(uint256 knightId) {
    require(isKnight(knightId),
      "KnightModifiers: Wrong id for knight");
    _;
  }

  function isInAnyClan(uint256 knightId) internal view virtual returns(bool) {
    return _knightClan(knightId) != 0;
  }

  modifier ifIsInAnyClan(uint256 knightId) {
    require(isInAnyClan(knightId),
      "KnightModifiers: This knight don't belong to any clan");
    _;
  }

  function isInClan(uint256 knightId, uint256 clanId) internal view virtual returns(bool) {
    return _knightClan(knightId) == clanId;
  }

  modifier ifIsInClan(uint256 knightId, uint256 clanId) {
    require(isInClan(knightId, clanId),
      "KnightModifiers: This knight don't belong to this clan");
    _;
  }

  function notInClan(uint256 knightId) internal view virtual returns(bool) {
    return _knightClan(knightId) == 0;
  }

  modifier ifNotInClan(uint256 knightId) {
    require(notInClan(knightId),
      "KnightModifiers: This knight already belongs to some clan");
    _;
  }
}
