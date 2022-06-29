// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.0;

import "./IERC1155Supply.sol";

interface IItems is IERC1155Supply {
  function ownerOfKnight(uint256 id) external view returns(address);
}