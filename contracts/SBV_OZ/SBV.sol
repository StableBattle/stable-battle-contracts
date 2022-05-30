// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.10;

import "./ERC721Enumerable.sol";

contract SBV is ERC721Enumerable {
  
  constructor (string memory name_,
               string memory symbol_,
               address[] memory beneficiaries)
              ERC721 (name_, symbol_) {
    for (uint i = 0; i < beneficiaries.length; i++) {
      ERC721._mint(beneficiaries[i], i + 1);
    }
  }

}