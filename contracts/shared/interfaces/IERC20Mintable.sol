// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.0;

import "./IERC20.sol";
import "./IERC20Metadata.sol";

interface IERC20Mintable is IERC20, IERC20Metadata {
  function mint(uint256) external;
}