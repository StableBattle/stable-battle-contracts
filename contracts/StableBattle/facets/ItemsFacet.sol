// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.0;

import { ERC1155Supply } from "./ERC1155Supply.sol";
import { IItems } from "../../shared/interfaces/IItems.sol";
import { ItemsStorage} from "../storage/ItemsStorage.sol";
import { KnightStorage, Knight } from "../storage/KnightStorage.sol";

contract ItemsFacet is ERC1155Supply, IItems {
  using ItemsStorage for ItemsStorage.Layout;
  using KnightStorage for KnightStorage.Layout;
    
  function _mint(address to, uint256 id, uint256 amount, bytes memory data) internal virtual override {
      super._mint(to, id, amount, data);
  }

  function _burn(address from, uint256 id, uint amount) internal virtual override {
      super._burn(from, id, amount);
  }

  function ownerOfKnight(uint256 id) external view returns(address) {
    return ItemsStorage.layout()._knightOwners[id];
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
    for (uint i = 0; i < ids.length; i++) {
      if (ids[i] >= KnightStorage.layout().knightOffset) {
        ItemsStorage.layout()._knightOwners[ids[i]] = to;
      }
    }
  }
}