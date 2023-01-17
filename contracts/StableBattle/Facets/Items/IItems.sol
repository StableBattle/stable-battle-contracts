// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { ISolidStateERC1155 } from "@solidstate/contracts/token/ERC1155/ISolidStateERC1155.sol";

interface IItemsEvents {}

interface IItemsErrors {
  error ItemsModifiers_DontOwnThisItem(uint256 itemId);
}

interface IItemsGetters {}

interface IItems is ISolidStateERC1155, IItemsEvents, IItemsErrors, IItemsGetters {}