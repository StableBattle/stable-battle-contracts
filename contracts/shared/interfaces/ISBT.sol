// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.0;

import "./IERC20.sol";

interface ISBT is IERC20 {

  function stake(uint clanId, uint256 amount) external;

  function withdraw(uint clanId, uint256 amount) external;

  function mint(address to, uint256 amount) external;

  function mintBatch (address[] memory to, uint256[] memory amount) external;

  function burn(address to, uint256 amount) external;

  function burnBatch (address[] memory to, uint256[] memory amount) external;

  function adminMint(address beneficiary, uint256 amount) external;

  event Stake(address benefactor, uint clanId, uint256 amount);
  event Withdraw(address benefactor, uint clanId, uint256 amount);
}