// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.0;

import { ERC1155BaseInternal } from "@solidstate/contracts/token/ERC1155/base/ERC1155BaseInternal.sol";

abstract contract ItemsModifiers is ERC1155BaseInternal {
  function ownsItem(uint256 itemId) internal view returns(bool) {
    return _balanceOf(msg.sender, itemId) > 0;
  }
  
  modifier ifOwnsItem(uint256 itemId) {
    require(ownsItem(itemId),
    "ItemModifiers: You don't own this item");
    _;
  }
}