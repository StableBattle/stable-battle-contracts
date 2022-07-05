// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.0;

import { ERC1155SupplyDummy } from "./ERC1155SupplyDummy.sol";
import { IItems } from "../../shared/interfaces/IItems.sol";

contract ItemsFacetDummy is ERC1155SupplyDummy, IItems {}