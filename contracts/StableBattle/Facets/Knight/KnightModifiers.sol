// SPDX-License-Identifier: Unlicensed

pragma solidity ^0.8.0;

import { KnightGetters } from "./KnightGetters.sol";
import { IKnightErrors } from "./IKnight.sol";

abstract contract KnightModifiers is IKnightErrors, KnightGetters {

  function isKnight(uint256 knightId) internal view virtual returns(bool) {
    return knightId >= type(uint256).max - _knightsMintedTotal();
  }
  
  modifier ifIsKnight(uint256 knightId) {
    if(!isKnight(knightId)) {
      revert KnightModifiers_WrongKnightId(knightId);
    }
    _;
  }

  function isInAnyClan(uint256 knightId) internal view virtual returns(bool) {
    return _knightClan(knightId) != 0;
  }

  modifier ifIsInAnyClan(uint256 knightId) {
    if(!isInAnyClan(knightId)) {
      revert KnightModifiers_KnightNotInAnyClan(knightId);
    }
    _;
  }

  function isInClan(uint256 knightId, uint256 clanId) internal view virtual returns(bool) {
    return _knightClan(knightId) == clanId;
  }

  modifier ifIsInClan(uint256 knightId, uint256 clanId) {
    uint256 knightClan = _knightClan(knightId);
    if(knightClan != clanId) {
      revert KnightModifiers_KnightNotInClan({
        knightId: knightId,
        wrongClanId: clanId,
        correctClanId: knightClan
      });
    }
    _;
  }

  function notInClan(uint256 knightId) internal view virtual returns(bool) {
    return _knightClan(knightId) == 0;
  }

  modifier ifNotInClan(uint256 knightId) {
    uint256 clanId = _knightClan(knightId);
    if (clanId != 0) {
      revert KnightModifiers_KnightInSomeClan(knightId, clanId);
    }
    _;
  }
}
