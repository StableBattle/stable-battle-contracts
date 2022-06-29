// SPDX-License-Identifier: Unlicensed

pragma solidity ^0.8.0;

import "./IItems.sol";

interface IForge is IItems {
  function mintItem(uint id, uint amount) external;

  function burnItem(uint id, uint amount) external;
}