// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.10;

import "./IERC20.sol";

interface IERC20Mintable is IERC20 {
  function mint(uint256) external;
}