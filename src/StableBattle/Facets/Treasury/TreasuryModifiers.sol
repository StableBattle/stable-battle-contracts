// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.0;

import { ITreasuryErrors } from "../Treasury/ITreasury.sol";

abstract contract TreasuryModifiers is ITreasuryErrors {
  function isFromAddress(address castleHolderAddress) internal view returns(bool) {
    return msg.sender == castleHolderAddress;
  }

  modifier ifIsFromAddress(address castleHolderAddress) {
    if(!isFromAddress(castleHolderAddress)){
    //revert TreasuryModifiers_OnlyCallableByCastleHolder();
      revert("Treasury Modifiers: Only Callable By Castle Holder");
    }
    _;
  }
}