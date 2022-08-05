// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.0;

import { UintUtils } from "./ERC1155/utils/UintUtils.sol";
import { SolidStateERC1155 } from "./ERC1155/SolidStateERC1155.sol";
import { ERC1155Metadata } from "./ERC1155/metadata/ERC1155Metadata.sol";
import { IERC1155Metadata } from "./ERC1155/metadata/IERC1155Metadata.sol";
import { ERC1155MetadataStorage } from "./ERC1155/metadata/ERC1155MetadataStorage.sol";

contract ItemsFacet is SolidStateERC1155 {
  using UintUtils for uint256;
  
  function uri(uint256 tokenId) 
    public
    view
    virtual
    override(ERC1155Metadata, IERC1155Metadata)
    returns (string memory)
  {
    ERC1155MetadataStorage.Layout storage l = ERC1155MetadataStorage.layout();

    string memory tokenIdURI = l.tokenURIs[tokenId];
    string memory baseURI = l.baseURI;

    if (bytes(baseURI).length == 0) {
        return tokenIdURI;
    } else if (bytes(tokenIdURI).length > 0) {
        return string(abi.encodePacked(baseURI, tokenIdURI));
    } else {
        return string(abi.encodePacked(baseURI, (type(uint256).max - tokenId).toString()));
    }
  }
}