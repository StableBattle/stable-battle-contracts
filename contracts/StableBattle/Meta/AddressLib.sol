// SPDX-License-Identifier: Unlicensed

pragma solidity ^0.8.0;

library AddressLib {
  bytes constant coin = abi.encode([
    address(0), //NONE
    address(0), //TEST
    0xC2C527C0CACF457746Bd31B2a698Fe89de2b6d49, //USDT
    0xA2025B15a1757311bfD68cb14eaeFCc237AF5b43, //USDC
    0xc31E63CB07209DFD2c7Edb3FB385331be2a17209 //EURS
  ]);

  bytes constant acoin = abi.encode([
    address(0), //NONE
    address(0), //TEST
    0x73258E6fb96ecAc8a979826d503B45803a382d68, //AUSDT
    0x1Ee669290939f8a8864497Af3BC83728715265FF, //AUSDC
    0xaA63E0C86b531E2eDFE9F91F6436dF20C301963D //AEURS
  ]);
}