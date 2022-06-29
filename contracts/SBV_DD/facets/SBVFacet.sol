// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.0;

import "./ERC721Enumerable.sol";
import { LibDiamond } from "../../shared/libraries/LibDiamond.sol";

contract SBVFacet is ERC721Enumerable {
  function _afterTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual override {
        super._afterTokenTransfer(from, to, tokenId);
        s.SBHook.SBV_hook(tokenId, to, (from == address(0)));
    }

  function adminMint(address beneficiary) external onlyOwner {
    _mint(beneficiary, totalSupply());
  }

  modifier onlyOwner() {
    LibDiamond.enforceIsContractOwner();
    _;
  }
}