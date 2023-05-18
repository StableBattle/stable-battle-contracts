// SPDX-License-Identifier: Unlicensed

pragma solidity ^0.8.0;

import { Coin, Pool } from "../Meta/DataStructures.sol";
import { GoerliAddressLib } from "./GoerliAddressLib.sol";

library SetupAddressLib {
  address constant AAVE = GoerliAddressLib.AAVEAddress;

  address constant USDT = GoerliAddressLib.USDTAddress;
  address constant USDC = GoerliAddressLib.USDCAddress;
  address constant EURS = GoerliAddressLib.EURSAddress;

  address constant AUSDT = GoerliAddressLib.AUSDTAddress;
  address constant AUSDC = GoerliAddressLib.AUSDCAddress;
  address constant AEURS = GoerliAddressLib.AEURSAddress;

  function getCoinAddress(Coin c) internal pure returns (address) {
  //return abi.decode(GoerliAddressLib.coin, (address[]))[uint8(c)];
    return
      c == Coin.USDT ? USDT :
      c == Coin.USDC ? USDC :
      c == Coin.EURS ? EURS :
      address(0);
  }

  function getACoinAddress(Coin c) internal pure returns (address) {
  //return abi.decode(GoerliAddressLib.acoin, (address[]))[uint8(c)];
    return
      c == Coin.USDT ? AUSDT :
      c == Coin.USDC ? AUSDC :
      c == Coin.EURS ? AEURS :
      address(0);
  }

  function getPoolAddress(Pool p) internal pure returns (address) {
    return
      p == Pool.AAVE ? AAVE :
      address(0);
  }

  function isCompatible(Pool p, Coin c) internal pure returns (bool) {
  //return abi.decode(GoerliAddressLib.compatibility, (bool[][]))[uint8(p)][uint8(c)];
    return
      p == Pool.AAVE ?
        c == Coin.USDT ? true :
        false :
      false;
  }
}