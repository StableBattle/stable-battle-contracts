// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.0;

import "./ERC721Enumerable.sol";
import { ISBV } from "../shared/interfaces/ISBV.sol";

contract SBV is ERC721Enumerable, ISBV {
  
  constructor (address[] memory beneficiaries)
              ERC721("StableBattle Villages", "SBV") {
    for (uint i = 0; i < beneficiaries.length; i++) {
      ERC721._mint(beneficiaries[i], i + 1);
    }
  }

  function adminMint(address beneficiary) external {
    _mint(beneficiary, totalSupply());
  }
}