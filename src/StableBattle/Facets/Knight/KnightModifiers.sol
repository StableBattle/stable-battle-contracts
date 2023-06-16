// SPDX-License-Identifier: Unlicensed

pragma solidity ^0.8.0;

import { IKnightErrors } from "./IKnight.sol";
import { ClanStorage } from "../Clan/ClanStorage.sol";
import { KnightStorage } from "./KnightStorage.sol";

abstract contract KnightModifiers is IKnightErrors {

  function isKnight(uint256 knightId) internal view virtual returns(bool) {
    return knightId >= type(uint256).max - KnightStorage.knightsMintedTotal();
  }
  
  modifier ifIsKnight(uint256 knightId) {
    if(!isKnight(knightId)) {
    //revert KnightModifiers_WrongKnightId(knightId);
      revert("Knight Modifiers: Wrong Knight Id");
    }
    _;
  }

  function isInAnyClan(uint256 knightId) internal view virtual returns(bool) {
    return KnightStorage.layout().knightClan[knightId] != 0;
  }

  modifier ifIsInAnyClan(uint256 knightId) {
    if(!isInAnyClan(knightId)) {
    //revert KnightModifiers_KnightNotInAnyClan(knightId);
      revert("Knight Modifiers: Knight Not In Any Clan");
    }
    _;
  }

  function isInClan(uint256 knightId, uint256 clanId) internal view virtual returns(bool) {
    return KnightStorage.layout().knightClan[knightId] == clanId;
  }

  modifier ifIsInClan(uint256 knightId, uint256 clanId) {
    uint256 knightClan = KnightStorage.layout().knightClan[knightId];
    if(knightClan != clanId) {
      /*
      revert KnightModifiers_KnightNotInClan({
        knightId: knightId,
        wrongClanId: clanId,
        correctClanId: knightClan
      });
      */
      revert("Knight Modifiers: Knight Not In Clan");
    }
    _;
  }

  function notInClan(uint256 knightId) internal view virtual returns(bool) {
    uint256 clanId = KnightStorage.layout().knightClan[knightId];
    // Either not in clan or clan abandoned
    return clanId == 0 || ClanStorage.layout().clanLeader[clanId] == 0;
  }

  modifier ifNotInClan(uint256 knightId) {
    if (!notInClan(knightId)) {
    //revert KnightModifiers_KnightInSomeClan(knightId, clanId);
      revert("Knight Modifiers: Knight In Some Clan");
    }
    _;
  }
}
