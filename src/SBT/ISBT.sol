// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.0;

import { ISolidStateERC20 } from "solidstate-solidity/token/ERC20/ISolidStateERC20.sol";
import { ISBTInternal } from "./ISBTInternal.sol";

interface ISBT is ISolidStateERC20, ISBTInternal {
  function adminMint(address account, uint256 amount) external;

  function adminBurn(address account, uint256 amount) external;

  function treasuryMint(address[] memory accounts, uint256[] memory amounts) external;

  function stake(uint clanId, uint256 amount) external;

  function withdraw(uint clanId, uint256 amount) external;
}