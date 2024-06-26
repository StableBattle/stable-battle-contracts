// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.0;

import { ERC1155BaseInternal } from "@solidstate/contracts/token/ERC1155/base/ERC1155BaseInternal.sol";
import { IItemsErrors } from "../Items/IItems.sol";

abstract contract ItemsModifiers is ERC1155BaseInternal, IItemsErrors {
  function ownsItem(uint256 itemId) internal view returns(bool) {
    return _balanceOf(msg.sender, itemId) > 0;
  }

  modifier ifOwnsItem(uint256 itemId) {
    if(!ownsItem(itemId)) {
    //revert ItemsModifiers_DontOwnThisItem(itemId);
      revert("Items Modifiers: Don't Own This Item");
    }
    _;
  }
}