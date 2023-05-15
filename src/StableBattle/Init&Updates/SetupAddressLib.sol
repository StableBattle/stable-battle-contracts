// SPDX-License-Identifier: Unlicensed

pragma solidity ^0.8.0;

import { Coin, Pool } from "../Meta/DataStructures.sol";
import { GoerliAddressLib } from "./GoerliAddressLib.sol";

library SetupAddressLib {
  function getCoinAddress(Coin c) internal pure returns (address) {
  //return abi.decode(GoerliAddressLib.coin, (address[]))[uint8(c)];
    if(c == Coin.NONE) return address(0);
    if(c == Coin.TEST) return address(0);
    if(c == Coin.USDT) return GoerliAddressLib.USDTAddress;
    if(c == Coin.USDC) return GoerliAddressLib.USDCAddress;
    if(c == Coin.EURS) return GoerliAddressLib.EURSAddress;
    return address(0);
  }

  function getACoinAddress(Coin c) internal pure returns (address) {
  //return abi.decode(GoerliAddressLib.acoin, (address[]))[uint8(c)];
    if(c == Coin.NONE) return address(0);
    if(c == Coin.TEST) return address(0);
    if(c == Coin.USDT) return GoerliAddressLib.AUSDTAddress;
    if(c == Coin.USDC) return GoerliAddressLib.AUSDCAddress;
    if(c == Coin.EURS) return GoerliAddressLib.AEURSAddress;
    return address(0);
  }

  function getPoolAddress(Pool p) internal pure returns (address) {
    if (p == Pool.AAVE) return GoerliAddressLib.AAVE;
    return address(0);
  }

  function isCompatible(Pool p, Coin c) internal pure returns (bool) {
  //return abi.decode(GoerliAddressLib.compatibility, (bool[][]))[uint8(p)][uint8(c)];
    if(p == Pool.NONE) return false;
    if(p == Pool.TEST) return false;
    if(p == Pool.AAVE) {
      if(c == Coin.NONE) return false;
      if(c == Coin.TEST) return false;
      if(c == Coin.USDT) return true;
      if(c == Coin.USDC) return false;
      if(c == Coin.EURS) return false;
    }
    return false;
  }
}