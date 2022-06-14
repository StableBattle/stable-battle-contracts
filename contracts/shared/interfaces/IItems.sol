// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.0;

import "./IERC1155Supply.sol";

interface IItems is IERC1155Supply {

  function mint(address to, uint256 id, uint amount) external;

  function burn(address from, uint256 id, uint amount) external;

  function ownerOfKnight(uint256 id) external view returns(address);
}