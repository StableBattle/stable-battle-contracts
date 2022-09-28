// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.0;

import { ISBV } from "./ISBV.sol";
import { SolidStateERC721 } from "solidstate-solidity/token/ERC721/SolidStateERC721.sol";
import { SBVGetters } from "./SBVGetters.sol";
import { OwnableInternal } from "solidstate-solidity/access/ownable/OwnableInternal.sol";

contract SBVImplementation is 
  ISBV,
  SolidStateERC721,
  SBVGetters,
  OwnableInternal
{
  function adminMint(address to, uint256 tokenId)
  external
  //onlyOwner
  {
    _mint(to, tokenId);
  }

  function adminBurn(uint256 tokenId)
  external
  //onlyOwner
  {
    _burn(tokenId);
  }

  function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual override {
        super._beforeTokenTransfer(from, to, tokenId);
        SBVHook().SBV_hook(tokenId, to, (from == address(0)));
    }
}