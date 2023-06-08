// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.0;

import { ISBV } from "./ISBV.sol";
import { ISBVHook } from "../StableBattle/Facets/SBVHook/ISBVHook.sol";
import { SolidStateERC721 } from "solidstate-solidity/token/ERC721/SolidStateERC721.sol";
import { OwnableInternal } from "solidstate-solidity/access/ownable/OwnableInternal.sol";
import { DiamondAddressLib } from "../StableBattle/Init&Updates/DiamondAddressLib.sol";

contract SBVImplementation is 
  ISBV,
  SolidStateERC721,
  OwnableInternal
{
  ISBVHook internal constant StableBattle = ISBVHook(DiamondAddressLib.DiamondAddress);

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
  ) internal override {
    super._beforeTokenTransfer(from, to, tokenId);
    bool isMint = (from == address(0));
    StableBattle.SBV_hook(tokenId, to, isMint);
  }
}