// SPDX-License-Identifier: Unlicensed
// Modified from the original OZ contract by adding DiamondStroage
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC1155/ERC1155.sol)

pragma solidity ^0.8.0;

import "../../shared/interfaces/IERC1155.sol";
import "../../shared/interfaces/IERC1155Receiver.sol";
import "../../shared/interfaces/IERC1155MetadataURI.sol";

contract ERC1155Dummy is IERC1155, IERC1155MetadataURI {

    function uri(uint256) public view virtual override returns (string memory) {}

    function balanceOf(address account, uint256 id) public view virtual override returns (uint256) {}

    function balanceOfBatch(address[] memory accounts, uint256[] memory ids)
        public
        view
        virtual
        override
        returns (uint256[] memory)
    {}

    function setApprovalForAll(address operator, bool approved) public virtual override {}

    function isApprovedForAll(address account, address operator) public view virtual override returns (bool) {}

    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) public virtual override {}

    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) public virtual override {}
}