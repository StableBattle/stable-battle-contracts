// SPDX-License-Identifier: Unlicensed

pragma solidity ^0.8.0;

import { Coin, Pool } from "../Meta/DataStructures.sol";

library GoerliAddressLib {
  bytes internal constant coin = abi.encode([
    address(0), //NONE
    address(0), //TEST
    0xC2C527C0CACF457746Bd31B2a698Fe89de2b6d49, //USDT
    0xA2025B15a1757311bfD68cb14eaeFCc237AF5b43, //USDC
    0xc31E63CB07209DFD2c7Edb3FB385331be2a17209 //EURS
  ]);

  address constant USDTAddress = 0xC2C527C0CACF457746Bd31B2a698Fe89de2b6d49;
  address constant USDCAddress = 0xA2025B15a1757311bfD68cb14eaeFCc237AF5b43;
  address constant EURSAddress = 0xc31E63CB07209DFD2c7Edb3FB385331be2a17209;

  bytes internal constant acoin = abi.encode([
    address(0), //NONE
    address(0), //TEST
    0x73258E6fb96ecAc8a979826d503B45803a382d68, //AUSDT
    0x1Ee669290939f8a8864497Af3BC83728715265FF, //AUSDC
    0xaA63E0C86b531E2eDFE9F91F6436dF20C301963D //AEURS
  ]);

  address constant AUSDTAddress = 0x73258E6fb96ecAc8a979826d503B45803a382d68;
  address constant AUSDCAddress = 0x1Ee669290939f8a8864497Af3BC83728715265FF;
  address constant AEURSAddress = 0xaA63E0C86b531E2eDFE9F91F6436dF20C301963D;

  address internal constant AAVEAddress = 0x368EedF3f56ad10b9bC57eed4Dac65B26Bb667f6;

  bytes internal constant compatibility = abi.encode([
    //NONE
    abi.encode([
      false, //NONE
      false, //TEST
      false, //USDT
      false, //USDC
      false //EURS
    ]),
    //TEST
    abi.encode([
      false, //NONE
      true, //TEST
      false, //USDT
      false, //USDC
      false //EURS
    ]),
    //AAVE
    abi.encode([
      false, //NONE
      false, //TEST
      true, //USDT
      false, //USDC
      false //EURS
    ])
  ]);

  function getCoinAddress(Coin c) internal pure returns (address) {
    return abi.decode(coin, (address[]))[uint8(c)];
  }

  function getACoinAddress(Coin c) internal pure returns (address) {
    return abi.decode(acoin, (address[]))[uint8(c)];
  }

  function getPoolAddress(Pool p) internal pure returns (address) {
    if (p == Pool.AAVE) return AAVEAddress;
    return address(0);
  }

  function isCompatible(Pool p, Coin c) internal pure returns (bool) {
    return abi.decode(compatibility, (bool[][]))[uint8(p)][uint8(c)];
  }
}