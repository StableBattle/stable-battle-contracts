// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.0;

import { IERC20 } from "@solidstate/contracts/token/ERC20/IERC20.sol";

contract StakeTransfer {
  address immutable public newSB;
  IERC20 constant public AUSDT = IERC20(0x73258E6fb96ecAc8a979826d503B45803a382d68);
  constructor(address _newSB) {
    newSB = _newSB;
  }

  function transferStake() external {
    AUSDT.transfer(newSB, AUSDT.balanceOf(address(this)));
  }
}