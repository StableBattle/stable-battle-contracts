// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.0;

import { Pool, Coin } from "../../Meta/DataStructures.sol";

interface IDebug {
  function debugSetBaseURI(string memory baseURI) external;

  function debugSetTokenURI(uint256 tokenId, string memory tokenURI) external;

  function debugSetKnightPrice(Coin coin, uint256 newPrice) external;

  function debugSetWithdrawalCooldown(uint256 clanId, address user, uint newCooldownEnd) external;

  function debugInheritKnightOwnership(address oldContractAddress, uint256 firstIdOffset, uint256 lastIdOffset) external;

  function debugBEERAddress() external pure returns(address);

  function debugSBVAddress() external pure returns(address);
}