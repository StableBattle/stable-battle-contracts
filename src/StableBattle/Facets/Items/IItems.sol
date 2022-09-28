// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { ISolidStateERC1155 } from "solidstate-solidity/token/ERC1155/ISolidStateERC1155.sol";
import { IItemsErrors } from "../Items/IItemsErrors.sol";

interface IItems is ISolidStateERC1155, IItemsErrors {}