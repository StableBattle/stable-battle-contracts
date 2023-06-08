// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.0;

import { ISolidStateERC20 } from "solidstate-solidity/token/ERC20/ISolidStateERC20.sol";
import { IOFTCore } from "./OFT/IOFTCore.sol";

interface IBEER is ISolidStateERC20 {
  function mint(address account, uint256 amount) external;

  function burn(address account, uint256 amount) external;

  function treasuryMint(address[] memory accounts, uint256[] memory amounts) external;
}