// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.10;

import { IERC20Base } from "@solidstate/contracts/token/ERC20/base/IERC20Base.sol";

interface IERC20Mintable is IERC20Base {
  function mint(address account, uint256 amount) external;
}