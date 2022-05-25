// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.10;

import {IERC20} from "./IERC20.sol";

interface ISBT is IERC20 {
  function mint(address _to, uint256 _value) external;
}