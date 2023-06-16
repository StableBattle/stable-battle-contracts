// SPDX-License-Identifier: Unlicensed

pragma solidity ^0.8.0;

import { Pool, Coin, Knight } from "../../Meta/DataStructures.sol";

library KnightStorage {
  struct Layout {
    mapping(uint256 => Pool) knightPool;
    mapping(uint256 => Coin) knightCoin;
    mapping(uint256 => address) knightOwner;
    mapping(uint256 => uint256) knightClan;
  //mapping(uint256 => Knight) knight;
    //!!!Deprecated, remove in next version!!!
    mapping(Coin => uint256) knightPrice;
    mapping(Pool => mapping(Coin => uint256)) knightsMinted;
    mapping(Pool => mapping(Coin => uint256)) knightsBurned;
  }

  bytes32 internal constant STORAGE_SLOT = keccak256("Knight.storage");

  function layout() internal pure returns (Layout storage l) {
    bytes32 slot = STORAGE_SLOT;
    assembly {
      l.slot := slot
    }
  }
  
  //returns amount of minted knights for a particular coin & pool
  function knightsMinted(Pool pool, Coin coin) internal view returns (uint256) {
    return layout().knightsMinted[pool][coin];
  }

  //returns amount of minted knights for any coin in a particular pool
  function knightsMintedOfPool(Pool pool) internal view returns (uint256 minted) {
    for (uint8 coin = 1; coin < uint8(type(Coin).max) + 1; coin++) {
      minted += layout().knightsMinted[pool][Coin(coin)];
    }
  }

  //returns amount of minted knights for any pool in a particular coin
  function knightsMintedOfCoin(Coin coin) internal view returns (uint256 minted) {
    for (uint8 pool = 1; pool < uint8(type(Pool).max) + 1; pool++) {
      minted += layout().knightsMinted[Pool(pool)][coin];
    }
  }

  //returns a total amount of minted knights
  function knightsMintedTotal() internal view returns (uint256 minted) {
    for (uint8 pool = 1; pool < uint8(type(Pool).max) + 1; pool++) {
      for (uint8 coin = 1; coin < uint8(type(Coin).max) + 1; coin++) {
        minted += layout().knightsMinted[Pool(pool)][Coin(coin)];
      }
    }
  }

  //returns amount of burned knights for a particular coin & pool
  function knightsBurned(Pool pool, Coin coin) internal view returns (uint256) {
    return layout().knightsBurned[pool][coin];
  }

  //returns amount of burned knights for any coin in a particular pool
  function knightsBurnedOfPool(Pool pool) internal view returns (uint256 burned) {
    for (uint8 coin = 1; coin < uint8(type(Coin).max) + 1; coin++) {
      burned += layout().knightsBurned[pool][Coin(coin)];
    }
  }

  //returns amount of burned knights for any pool in a particular coin
  function knightsBurnedOfCoin(Coin coin) internal view returns (uint256 burned) {
    for (uint8 pool = 1; pool < uint8(type(Pool).max) + 1; pool++) {
      burned += layout().knightsBurned[Pool(pool)][coin];
    }
  }

  //returns a total amount of burned knights
  function knightsBurnedTotal() internal view returns (uint256 burned) {
    for (uint8 pool = 1; pool < uint8(type(Pool).max) + 1; pool++) {
      for (uint8 coin = 1; coin < uint8(type(Coin).max) + 1; coin++) {
        burned += layout().knightsBurned[Pool(pool)][Coin(coin)];
      }
    }
  }

  function totalKnightSupply() internal view returns (uint256) {
    return knightsMintedTotal() - knightsBurnedTotal();
  }
}