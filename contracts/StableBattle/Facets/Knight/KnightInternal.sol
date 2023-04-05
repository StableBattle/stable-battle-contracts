// SPDX-License-Identifier: Unlicensed

pragma solidity ^0.8.10;

import { Coin, Pool, Knight, ClanRole } from "../../Meta/DataStructures.sol";

import { IKnightEvents, IKnightErrors } from "../Knight/IKnight.sol";
import { KnightStorage } from "../Knight/KnightStorage.sol";
import { KnightGetters } from "../Knight/KnightGetters.sol";
import { KnightModifiers } from "../Knight/KnightModifiers.sol";
import { ClanInternal } from "../Clan/ClanInternal.sol";
import { MetaModifiers } from "../../Meta/MetaModifiers.sol";
import { ExternalCalls } from "../../Meta/ExternalCalls.sol";

abstract contract KnightInternal is
  IKnightEvents,
  KnightGetters,
  KnightModifiers,
  ClanInternal,
  MetaModifiers,
  ExternalCalls
{
  function _mintKnight(Pool p, Coin c) internal returns (uint256) {
    uint256 knightPrice = _knightPrice(c);
    if (c != Coin.TEST) {
      // Check if user gave its approval for enough COIN
      uint256 allowance = COIN(c).allowance(msg.sender, address(this));
      if (allowance < knightPrice) {
        revert KnightFacet_InsufficientFunds(allowance, knightPrice);
      }
      // Transfer enough COIN from user to contract
      COIN(c).transferFrom(msg.sender, address(this), knightPrice);
      // Approve COIN for Pool
      COIN(c).approve(PoolAddress(p), knightPrice);
    }
    if (p == Pool.AAVE) {
      AAVE().supply(address(COIN(c)), knightPrice, address(this), 0);
    }
    // Mint NFT for the user
    uint256 knightId = type(uint256).max - _knightsMintedTotal();
    _mint(msg.sender, knightId, 1, "");
    KnightStorage.state().knightsMinted[p][c]++;
    //Initialize Knight
    KnightStorage.state().knightPool[knightId] = p;
    KnightStorage.state().knightCoin[knightId] = c;
    KnightStorage.state().knightOwner[knightId] = msg.sender;
    KnightStorage.state().knightClan[knightId] = 0;

    emit KnightMinted(knightId, msg.sender, p, c);
    return knightId;
  }

  function _burnKnight(uint256 knightId, uint256 heirId) internal {
    Pool p = _knightPool(knightId);
    Coin c = _knightCoin(knightId);
    //Leave or abandon clan
    uint256 clanId = _knightClan(knightId);
    uint256 leaderId = _clanLeader(clanId);
    if (clanId != 0 && leaderId != 0) {
      if (knightId == leaderId) {
        if(heirId != 0) {
          if(!isKnight(heirId)) {
            revert KnightFacet_HeirIsNotKnight(heirId);
          }
          if(_knightClan(heirId) != clanId) {
            revert KnightFacet_HeirIsNotInTheSameClan(clanId, heirId);
          }
          _setClanRole(clanId, knightId, ClanRole.ADMIN);
          _setClanRole(clanId, heirId, ClanRole.OWNER);
        } else {
          _abandonClan(clanId, knightId);
        }
      } else {
        _kick(knightId, clanId);
      }
    }
    // Null the knight
    KnightStorage.state().knightPool[knightId] = Pool.NONE;
    KnightStorage.state().knightCoin[knightId] = Coin.NONE;
    KnightStorage.state().knightOwner[knightId] = address(0);
    KnightStorage.state().knightClan[knightId] = 0;
    // Burn NFT
    _burn(msg.sender, knightId, 1);
    KnightStorage.state().knightsBurned[p][c]++;
    if (p == Pool.AAVE) {
    // Withraw price in Coin from AAVE to the user
      AAVE().withdraw(address(COIN(c)), _knightPrice(c), msg.sender);
    }
    emit KnightBurned(knightId, msg.sender, p, c);
  }
}