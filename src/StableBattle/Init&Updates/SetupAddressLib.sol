// SPDX-License-Identifier: Unlicensed

pragma solidity ^0.8.0;

import { Coin, Pool } from "../Meta/DataStructures.sol";
import { GoerliAddressLib } from "./GoerliAddressLib.sol";

library SetupAddressLib {
  function getCoinAddress(Coin c) internal pure returns (address) {
    return abi.decode(GoerliAddressLib.coin, (address[]))[uint8(c)];
  }

  function getACoinAddress(Coin c) internal pure returns (address) {
    return abi.decode(GoerliAddressLib.acoin, (address[]))[uint8(c)];
  }

  function getPoolAddress(Pool p) internal pure returns (address) {
    if (p == Pool.AAVE) return GoerliAddressLib.AAVE;
    return address(0);
  }

  function isCompatible(Pool p, Coin c) internal pure returns (bool) {
    return abi.decode(GoerliAddressLib.compatibility, (bool[][]))[uint8(p)][uint8(c)];
  }
}