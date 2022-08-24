// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.0;

import { UintUtils } from "../Items/ERC1155/utils/UintUtils.sol";
import { SolidStateERC1155 } from "../Items/ERC1155/SolidStateERC1155.sol";
import { ERC1155Metadata } from "../Items/ERC1155/metadata/ERC1155Metadata.sol";
import { IERC1155Metadata } from "../Items/ERC1155/metadata/IERC1155Metadata.sol";
import { ERC1155MetadataStorage } from "../Items/ERC1155/metadata/ERC1155MetadataStorage.sol";

contract ItemsFacet is SolidStateERC1155 {}