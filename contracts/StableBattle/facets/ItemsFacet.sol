// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.0;

import { ERC1155Supply } from "../../OZ_ERC1155_DS/ERC1155Supply.sol";
import { IItems } from "../../shared/interfaces/IItems.sol";

import { ItemsStorage as ITEM } from "../storage/ItemsStorage.sol";
//import { KnightStorage as KNHT, knightType } from "../storage/KnightStorage.sol";

contract ItemsFacet is ERC1155Supply, IItems {
  using ITEM for ITEM.State;
//using KNHT for KNHT.State;
    
  function _mint(address to, uint256 id, uint256 amount, bytes memory data) internal virtual override {
      super._mint(to, id, amount, data);
  }

  function _burn(address from, uint256 id, uint amount) internal virtual override {
      super._burn(from, id, amount);
  }

  function _afterTokenTransfer(
    address operator,
    address from,
    address to,
    uint256[] memory ids,
    uint256[] memory amounts,
    bytes memory data
  ) internal virtual override {
    super._afterTokenTransfer(operator, from, to, ids, amounts, data);
    /*
    for (uint i = 0; i < ids.length; i++) {
      if (ids[i] >= KNHT.knightOffset()) {
        knightType kt = abi.decode(data, (knightType));
        if (from == address(0)) { KNHT.state().knightsMinted[kt]++; }
        else if (to == address(0)) { KNHT.state().knightsBurned[kt]++; }
      }
    }
    */
  }
}