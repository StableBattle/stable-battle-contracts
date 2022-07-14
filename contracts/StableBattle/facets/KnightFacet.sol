// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.0;

import { ItemsFacet } from "./ItemsFacet.sol";
import { IKnight } from "../../shared/interfaces/IKnight.sol";
//import { IClan } from "../../shared/interfaces/IClan.sol";

import { KnightStorage as KNHT, Knight, KnightGetters, KnightModifiers} from "../storage/KnightStorage.sol";
import { Pool, Coin, ExternalCalls, MetaModifiers } from "../storage/MetaStorage.sol";
import { ItemsModifiers } from "../storage/ItemsStorage.sol";
//import { ClanStorage as CLAN } from "../storage/ClanStorage.sol";

contract KnightFacet is ItemsFacet,
                        IKnight,
                        KnightGetters,
                        KnightModifiers,
                        ExternalCalls,
                        ItemsModifiers,
                        MetaModifiers
{
  using KNHT for KNHT.State;
//using CLAN for CLAN.State;

  function mintKnight(Pool p, Coin c)
    public
    ifIsValidCoin(c)
    ifIsVaildPool(p)
    ifIsCompatible(p, c)
  {
    if (c == Coin.USDT) {
      // Check if user gave its approval for enough COIN
      require(COIN(c).allowance(msg.sender, address(this)) >= knightPrice(c), 
        "KnightFacet: User allocated insufficient amount of funds");
      // Transfer enough COIN from user to contract
      COIN(c).transferFrom(msg.sender, address(this), knightPrice(c));
      // Approve COIN for Pool
      COIN(c).approve(PoolAddress(p), knightPrice(c));
    }
    if (p == Pool.AAVE) {
      AAVE().supply(address(COIN(c)), knightPrice(c), address(this), 0);
    }
    // Mint NFT for the user
    uint256 knightId = type(uint256).max - knightsMintedTotal();
    _mint(msg.sender, knightId, 1, "");
    KNHT.state().knightsMinted[p][c]++;
    //Initialize Knight
    KNHT.state().knight[knightId] = Knight(p, c, msg.sender, 0, 0);

    emit KnightMinted(knightId, msg.sender, p, c);
  }

  function burnKnight (uint256 knightId)
    external
    ifIsKnight(knightId)
    ifOwnsItem(knightId)
  //ifIsVaildPool(knightPool(knightId))
  //ifIsValidCoin(knightCoin(knightId))
  //ifIsCompatible(c, p)
  {
    Pool p = knightPool(knightId);
    Coin c = knightCoin(knightId);
  /*
    uint256 ownerId = knightClanOwnerOf(knightId);
    uint256 clanId = knightClan(knightId);
    //Dissolve knight's clan and/or kick him out
    if (ownerId != 0) {
    //Copy of disslove(uint256) from ClanFacet
    //Should think of a better way to do this
    //Maybe worth a CALL
      KNHT.state().knight[ownerId].ownsClan = 0;
      KNHT.state().knight[ownerId].inClan = 0;
      CLAN.state().clan[clanId].owner = 0;
      emit IClan.ClanDissloved(clanId, ownerId, true);
    }
    if (clanId != 0) {
    //Copy of acceptLeave() from ClanFacet
    //Should think of a better way to do this
    //Maybe worth a CALL
      CLAN.state().clan[clanId].totalMembers--;
      KNHT.state().knight[knightId].inClan = 0;
      CLAN.state().leaveProposal[knightId] = 0;
      emit IClan.KnightLeavedClan(clanId, knightId, true);
    }
  */
    // Null the knight
    KNHT.state().knight[knightId] = Knight(Pool.NONE, Coin.NONE, address(0), 0, 0);
    // Burn NFT
    _burn(msg.sender, knightId, 1);
    KNHT.state().knightsBurned[p][c]++;
    if (p == Pool.AAVE) {
    // Withraw price in Coin from AAVE to the user
      AAVE().withdraw(address(COIN(c)), knightPrice(c), msg.sender);
    }
    emit KnightBurned(knightId, msg.sender, p, c);
  }

//Public Getters

  function getKnightInfo(uint256 knightId) external view returns(Knight memory) {
    return knightInfo(knightId);
  }

  function getKnightCoin(uint256 knightId) external view returns(Coin) {
    return knightCoin(knightId);
  }

  function getKnightPool(uint256 knightId) external view returns(Pool) {
    return knightPool(knightId);
  }

  function getKnightOwner(uint256 knightId) external view returns(address) {
    return knightOwner(knightId);
  }

  function getKnightClan(uint256 knightId) external view returns(uint256) {
    return knightClan(knightId);
  }

  function getKnightClanOwnerOf(uint256 knightId) external view returns(uint256) {
    return knightClanOwnerOf(knightId);
  }

  function getKnightPrice(Coin coin) external view returns (uint256) {
    return knightPrice(coin);
  }

  //returns amount of minted knights for a particular coin & pool
  function getKnightsMinted(Pool pool, Coin coin) external view returns (uint256) {
    return knightsMinted(pool, coin);
  }

  //returns amount of minted knights for any coin in a particular pool
  function getKnightsMintedOfPool(Pool pool) external view returns (uint256 knightsMintedTotal) {
    return knightsMintedOfPool(pool);
  }

  //returns amount of minted knights for any pool in a particular coin
  function getKnightsMintedOfCoin(Coin coin) external view returns (uint256) {
    return knightsMintedOfCoin(coin);
  }

  //returns a total amount of minted knights
  function getKnightsMintedTotal() external view returns (uint256) {
    return knightsMintedTotal();
  }

  //returns amount of burned knights for a particular coin & pool
  function getKnightsBurned(Pool pool, Coin coin) external view returns (uint256) {
    return knightsBurned(pool, coin);
  }

  //returns amount of burned knights for any coin in a particular pool
  function getKnightsBurnedOfPool(Pool pool) external view returns (uint256 knightsBurnedTotal) {
    return knightsBurnedOfPool(pool);
  }

  //returns amount of burned knights for any pool in a particular coin
  function getKnightsBurnedOfCoin(Coin coin) external view returns (uint256) {
    return knightsBurnedOfCoin(coin);
  }

  //returns a total amount of burned knights
  function getKnightsBurnedTotal() external view returns (uint256) {
    return knightsBurnedTotal();
  }

  function getTotalKnightSupply() external view returns (uint256) {
    return totalKnightSupply();
  }

  function getPoolAndCoinCompatibility(Pool p, Coin c) external view returns (bool) {
    return PoolAndCoinCompatibility(p, c);
  }
}