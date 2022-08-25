// SPDX-License-Identifier: Unlicensed

pragma solidity ^0.8.10;

import { Coin, Pool, Knight } from "../../Meta/DataStructures.sol";

import { IKnightInternal } from "../Knight/IKnightInternal.sol";
import { KnightStorage } from "../Knight/KnightStorage.sol";
import { KnightGetters } from "../Knight/KnightGetters.sol";
import { KnightModifiers } from "../Knight/KnightModifiers.sol";
import { ClanInternal } from "../Clan/ClanInternal.sol";
import { MetaModifiers } from "../../Meta/MetaModifiers.sol";
import { ExternalCalls } from "../../Meta/ExternalCalls.sol";
import { ERC1155BaseInternal } from "@solidstate/contracts/token/ERC1155/base/ERC1155BaseInternal.sol";

abstract contract KnightInternal is
  IKnightInternal,
  //ERC1155BaseInternal,
  KnightGetters,
  KnightModifiers,
  ClanInternal,
  MetaModifiers, 
  ExternalCalls
{
  using KnightStorage for KnightStorage.State;

  function _mintKnight(Pool p, Coin c)
    internal
    ifIsValidCoin(c)
    ifIsVaildPool(p)
    ifIsCompatible(p, c)
  {
    if (c != Coin.TEST) {
      // Check if user gave its approval for enough COIN
      require(COIN(c).allowance(msg.sender, address(this)) >= _knightPrice(c), 
        "KnightFacet: User allocated insufficient amount of funds");
      // Transfer enough COIN from user to contract
      COIN(c).transferFrom(msg.sender, address(this), _knightPrice(c));
      // Approve COIN for Pool
      COIN(c).approve(PoolAddress(p), _knightPrice(c));
    }
    if (p == Pool.AAVE) {
      AAVE().supply(address(COIN(c)), _knightPrice(c), address(this), 0);
    }
    // Mint NFT for the user
    uint256 knightId = type(uint256).max - _knightsMintedTotal();
    _mint(msg.sender, knightId, 1, "");
    KnightStorage.state().knightsMinted[p][c]++;
    //Initialize Knight
    KnightStorage.state().knight[knightId] = Knight(p, c, msg.sender, 0);

    emit KnightMinted(knightId, msg.sender, p, c);
  }

  function _burnKnight(uint256 knightId)
    internal
    ifIsKnight(knightId)
    ifIsVaildPool(_knightPool(knightId))
    ifIsValidCoin(_knightCoin(knightId))
    ifIsCompatible(_knightPool(knightId), _knightCoin(knightId))
  {
    Pool p = _knightPool(knightId);
    Coin c = _knightCoin(knightId);
    //Leave or abandon clan
    uint256 clanId = _knightClan(knightId);
    uint256 leaderId = _clanLeader(clanId);
    if (clanId != 0 && leaderId != 0) {
      knightId == leaderId ?
        _abandon(clanId) :
        _kick(knightId);
    }
    // Null the knight
    KnightStorage.state().knight[knightId] = Knight(Pool.NONE, Coin.NONE, address(0), 0);
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