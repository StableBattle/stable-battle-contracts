// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { LibDiamond } from "../../Diamond/LibDiamond.sol";

contract OwnershipModifiers {
  modifier onlyOwner() {
    LibDiamond.enforceIsContractOwner();
    _;
  }
}
