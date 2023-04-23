// SPDX-License-Identifier: Unlicensed

pragma solidity ^0.8.0;

import { Coin, Pool } from "../Meta/DataStructures.sol";
import { MetaStorage } from "../Meta/MetaStorage.sol";

abstract contract MetaModifiers {
  error InvalidPool(Pool pool);
  
  function isVaildPool(Pool pool) internal view virtual returns(bool) {
    return pool != Pool.NONE ? true : false;
  }

  modifier ifIsVaildPool(Pool pool) {
    if (!isVaildPool(pool)) {
    //revert InvalidPool(pool);
      revert("MetaModifiers: Invalid pool");
    }
    _;
  }

  error InvalidCoin(Coin coin);

  function isValidCoin(Coin coin) internal view virtual returns(bool) {
    return coin != Coin.NONE ? true : false;
  }

  modifier ifIsValidCoin(Coin coin) {
    if (!isValidCoin(coin)) {
    //revert InvalidCoin(coin);
      revert("MetaModifiers: Invalid coin");
    }
    _;
  }

  error IncompatiblePoolCoin(Pool pool, Coin coin);

  function isCompatible(Pool pool, Coin coin) internal view virtual returns(bool) {
    return MetaStorage.state().compatible[pool][coin];
  }

  modifier ifIsCompatible(Pool pool, Coin coin) {
    if (!isCompatible(pool, coin)) {
    //revert IncompatiblePoolCoin(pool, coin);
      revert("MetaModifiers: Incompatible pool coin");
    }
    _;
  }

  error CallerNotSBV();

  function isSBV() internal view virtual returns(bool) {
    return MetaStorage.state().SBV == msg.sender;
  }

  modifier ifIsSBV {
    if (!isSBV()) {
    //revert CallerNotSBV();
      revert("MetaModifiers: Caller not Stable Battle Villages");
    }
    _;
  }

  error CallerNotBEER();

  function isBEER() internal view virtual returns(bool) {
    return MetaStorage.state().BEER == msg.sender;
  }

  modifier ifIsBEER {
    if (!isBEER()) {
    //revert CallerNotBEER();
      revert("MetaModifiers: Caller not BEER token contract");
    }
    _;
  }

  error CallerNotSBD();

  function isSBD() internal view virtual returns(bool) {
    return address(this) == msg.sender;
  }

  modifier ifIsSBD {
    if (!isSBD()) {
    //revert CallerNotSBD();
      revert("MetaModifiers: Caller not main StableBattle contract");
    }
    _;
  }
}