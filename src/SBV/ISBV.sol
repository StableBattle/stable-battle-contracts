// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.0;

import { ISolidStateERC721 } from "solidstate-solidity/token/ERC721/ISolidStateERC721.sol";

interface ISBVEvents {}

interface ISBV is ISolidStateERC721, ISBVEvents {
  function adminMint(address to, uint256 tokenId) external;

  function adminBurn(uint256 tokenId) external;

  function diamondAddress() external pure returns(address);
}