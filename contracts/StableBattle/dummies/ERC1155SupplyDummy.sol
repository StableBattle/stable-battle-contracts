// SPDX-License-Identifier: Unlicensed
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC1155/extensions/ERC1155Supply.sol)

pragma solidity ^0.8.0;

import "./ERC1155Dummy.sol";
import "../../shared/interfaces/IERC1155Supply.sol";

abstract contract ERC1155SupplyDummy is ERC1155Dummy, IERC1155Supply {
    function totalSupply(uint256 id) public view virtual returns (uint256) {}

    function exists(uint256 id) public view virtual returns (bool) {}
}
