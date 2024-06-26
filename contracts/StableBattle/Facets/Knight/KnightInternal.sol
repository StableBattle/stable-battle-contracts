// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.0;

import { Coin, Pool, Knight, ClanRole } from "../../Meta/DataStructures.sol";

import { IKnightEvents, IKnightErrors } from "../Knight/IKnight.sol";
import { KnightStorage } from "../Knight/KnightStorage.sol";
import { KnightGetters } from "../Knight/KnightGetters.sol";
import { KnightModifiers } from "../Knight/KnightModifiers.sol";
import { ClanInternal } from "../Clan/ClanInternal.sol";
import { ExternalCalls } from "../../Meta/ExternalCalls.sol";

abstract contract KnightInternal is
  IKnightEvents,
  KnightGetters,
  KnightModifiers,
  ClanInternal,
  ExternalCalls
{
  function _mintKnight(Pool p, Coin c) internal returns (uint256) {
    uint256 knightPrice = _knightPrice(c);
    if (c != Coin.TEST) {
      // Check if user gave its approval for enough COIN
      uint256 allowance = COIN(c).allowance(msg.sender, address(this));
      if (allowance < knightPrice) {
      //revert KnightFacet_InsufficientFunds(allowance, knightPrice);
        revert("KnightFacet: Insufficient allowance");
      }
      // Transfer enough COIN from user to contract
      COIN(c).transferFrom(msg.sender, address(this), knightPrice);
      // Approve COIN for Pool
      COIN(c).approve(PoolAddress(p), knightPrice);
    }
    if (p == Pool.AAVE) {
      AAVE.supply(address(COIN(c)), knightPrice, address(this), 0);
    }
    // Mint NFT for the user
    uint256 knightId = type(uint256).max - _knightsMintedTotal();
    _mint(msg.sender, knightId, 1, "");
    KnightStorage.layout().knightsMinted[p][c]++;
    //Initialize Knight
    KnightStorage.layout().knightPool[knightId] = p;
    KnightStorage.layout().knightCoin[knightId] = c;
    KnightStorage.layout().knightOwner[knightId] = msg.sender;
    KnightStorage.layout().knightClan[knightId] = 0;

    emit KnightMinted(knightId, msg.sender, p, c);
    return knightId;
  }

  function _burnKnight(uint256 knightId) internal {
    Pool p = _knightPool(knightId);
    Coin c = _knightCoin(knightId);
    // Null the knight
    KnightStorage.layout().knightOwner[knightId] = address(0);
    // Burn NFT
    _burn(msg.sender, knightId, 1);
    KnightStorage.layout().knightsBurned[p][c]++;
    if (p == Pool.AAVE) {
    // Withraw price in Coin from AAVE to the user
      AAVE.withdraw(address(COIN(c)), _knightPrice(c), msg.sender);
    }
    emit KnightBurned(knightId, msg.sender, p, c);
  }
}