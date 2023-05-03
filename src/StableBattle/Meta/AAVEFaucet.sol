// SPDX-License-Identifier: None

pragma solidity ^0.8.0;

interface Faucet {
  function mint(address token, address to, uint256 amount) external returns (uint256);
}