// SPDX-License-Identifier: Unlicensed

pragma solidity ^0.8.0;

import { Pool, Coin, MetaStorage } from "./MetaStorage.sol";

abstract contract MetaModifiers {
  using MetaStorage for MetaStorage.State;
  
  function isVaildPool(Pool pool) internal view virtual returns(bool) {
    return pool != Pool.NONE ? true : false;
  }

  modifier ifIsVaildPool(Pool pool) {
    require(isVaildPool(pool), "MetaModifiers: This is not a valid pool");
    _;
  }

  function isValidCoin(Coin coin) internal view virtual returns(bool) {
    return coin != Coin.NONE ? true : false;
  }

  modifier ifIsValidCoin(Coin coin) {
    require(isValidCoin(coin), "MetaModifiers: This is not a valid coin");
    _;
  }

  function isCompatible(Pool p, Coin c) internal view virtual returns(bool) {
    return MetaStorage.state().compatible[p][c];
  }

  modifier ifIsCompatible(Pool p, Coin c) {
    require(isCompatible(p, c), "MetaModifiers: This token is incompatible with this pool");
    _;
  }

  function isSBV() internal view virtual returns(bool) {
    return MetaStorage.state().SBV == msg.sender;
  }

  modifier ifIsSBV {
    require(isSBV(), "MetaModifiers: can only be called by SBV");
    _;
  }

  function isSBT() internal view virtual returns(bool) {
    return MetaStorage.state().SBT == msg.sender;
  }

  modifier ifIsSBT {
    require(isSBT(),
      "MetaModifiers: can only be called by SBT");
    _;
  }

  function isSBD() internal view virtual returns(bool) {
    return address(this) == msg.sender;
  }

  modifier ifIsSBD {
    require(isSBD(), "MetaModifiers: can only be called by StableBattle");
    _;
  }
}