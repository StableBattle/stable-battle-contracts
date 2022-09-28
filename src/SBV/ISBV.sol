// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.0;

import { ISolidStateERC721 } from "solidstate-solidity/token/ERC721/ISolidStateERC721.sol";
import { ISBVInternal } from "./ISBVInternal.sol";

interface ISBV is ISolidStateERC721, ISBVInternal {
  function adminMint(address to, uint256 tokenId) external;

  function adminBurn(uint256 tokenId) external;
}