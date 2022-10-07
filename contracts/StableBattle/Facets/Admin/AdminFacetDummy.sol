// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.0;

import { Pool, Coin } from "../../Meta/DataStructures.sol";

contract AdminFacetDummy {
  function setBaseURI(string memory baseURI) external {}

  function setTokenURI(uint256 tokenId, string memory tokenURI) external {}

  function debugEnablePoolCoinMinting(Pool pool, Coin coin) external {}

  function debugDisablePoolCoinMinting(Pool pool, Coin coin) external {}
}