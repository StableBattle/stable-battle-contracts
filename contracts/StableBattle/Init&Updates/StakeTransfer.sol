// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.0;

import { AToken } from "@aave/core-v3/contracts/protocol/tokenization/AToken.sol";

contract StakeTransfer {
  address immutable public newSB;
  AToken constant public AUSDT = AToken(0x73258E6fb96ecAc8a979826d503B45803a382d68);
  constructor(address _newSB) {
    newSB = _newSB;
  }

  function transferStake() external {
    AUSDT.transfer(newSB, AUSDT.balanceOf(address(this)));
  }
}