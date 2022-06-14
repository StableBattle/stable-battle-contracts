// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.0;

import "./IERC1155.sol";

interface IERC1155Supply is IERC1155 {
  function totalSupply(uint256 id) external view returns (uint256);

  function exists(uint256 id) external view returns (bool);
}
