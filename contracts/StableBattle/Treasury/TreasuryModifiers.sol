// SPDX-License-Identifier: Unlicensed

pragma solidity ^0.8.0;

abstract contract TreasuryModifiers {
  function isFromAddress(address castleHolderAddress) internal view returns(bool) {
    return msg.sender == castleHolderAddress;
  }

  modifier ifIsFromAddress(address castleHolderAddress) {
    require(isFromAddress(castleHolderAddress),
      "TreasuryFacet: Only a specific address can use this function");
    _;
  }
}