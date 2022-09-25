// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.0;

import { ITreasuryErrors } from "../Treasury/ITreasuryErrors.sol";

abstract contract TreasuryModifiers is ITreasuryErrors {
  function isFromAddress(address castleHolderAddress) internal view returns(bool) {
    return msg.sender == castleHolderAddress;
  }

  modifier ifIsFromAddress(address castleHolderAddress) {
    if(!isFromAddress(castleHolderAddress)){
      revert TreasuryModifiers_OnlyCallableByCastleHolder();
    }
    _;
  }
}