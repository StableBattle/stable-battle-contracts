// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IItemsErrors {
  error ItemsFacet_DontOwnThisItem(uint256 itemId);
}