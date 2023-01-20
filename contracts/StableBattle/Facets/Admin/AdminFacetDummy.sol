// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.0;

import { Pool, Coin } from "../../Meta/DataStructures.sol";

contract AdminFacetDummy {
  function adminSetBaseURI(string memory baseURI) external {}

  function adminSetTokenURI(uint256 tokenId, string memory tokenURI) external {}

  function adminEnablePoolCoinMinting(Pool pool, Coin coin) external {}

  function adminDisablePoolCoinMinting(Pool pool, Coin coin) external {}

  function adminSetCoinAddress(Coin coin, address newAddress) external {}

  function adminSetACoinAddress(Coin coin, address newAddress) external {}

  function adminSetKnightPrice(Coin coin, uint256 newPrice) external {}

  function adminSetLevelThresholds(uint[] memory newThresholds) external {}
}