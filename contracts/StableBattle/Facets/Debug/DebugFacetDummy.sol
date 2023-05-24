// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.0;

import { Pool, Coin } from "../../Meta/DataStructures.sol";
import { IDebug } from "../Debug/IDebug.sol";

contract DebugFacetDummy is IDebug {
  function debugSetBaseURI(string memory baseURI) external {}

  function debugSetTokenURI(uint256 tokenId, string memory tokenURI) external {}

  function debugEnablePoolCoinMinting(Pool pool, Coin coin) external {}

  function debugDisablePoolCoinMinting(Pool pool, Coin coin) external {}

  function debugSetCoinAddress(Coin coin, address newAddress) external {}

  function debugSetACoinAddress(Coin coin, address newAddress) external {}

  function debugSetKnightPrice(Coin coin, uint256 newPrice) external {}

  function debugSetLevelThresholds(uint[] memory newThresholds) external {}
  
  function debugSetWithdrawalCooldown(uint256 clanId, address user, uint newCooldownEnd) external {}

  function debugInheritKnightOwnership(address oldContractAddress, uint256 firstIdOffset, uint256 lastIdOffset) external {}

  function debugBEERAddress() external pure returns(address) {}

  function debugSBVAddress() external pure returns(address) {}
}