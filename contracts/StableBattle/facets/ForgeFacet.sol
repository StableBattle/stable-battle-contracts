// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.10;
import { ERC1155 } from "./ERC1155Facet.sol";

abstract contract ForgeFacet is ERC1155 {

  function mintItem (uint item_id, uint amount) public {
    _mint(msg.sender, item_id, amount, '');
  }

  function burnItem (uint item_id, uint amount) public {
    require (balanceOf(msg.sender, item_id) >= amount, "Insufficient amount of items to burn");
    _burn(msg.sender, item_id, amount);
  }
}