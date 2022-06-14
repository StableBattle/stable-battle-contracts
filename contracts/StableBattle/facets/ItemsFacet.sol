// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.0;

import { ERC1155Supply } from "./ERC1155Supply.sol";
import { IItems } from "../../shared/interfaces/IItems.sol";
import { Knight } from "../libraries/LibAppStorage.sol";

contract ItemsFacet is ERC1155Supply, IItems {

  modifier onlyItemForges() {
    bool sentByItemForge;
    for (uint i = 0; i < s.ItemForges.length; ++i) {
      if (msg.sender == s.ItemForges[i]) {
        sentByItemForge = true;
        break;
      }
    }
    require(sentByItemForge, "Items: this function can only be called by either Kinght or Forge facets");
    _;
  }

  function mint(address to, uint256 id, uint amount) external onlyItemForges {
    ERC1155Supply._mint(to, id, amount, '');
  }

  function burn(address from, uint256 id, uint amount) external onlyItemForges {
    ERC1155Supply._burn(from, id, amount);
  }

  function ownerOfKnight(uint256 id) external view returns(address) {
    return s._knightOwners[id];
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
      if (ids[i] >= s.knight_offset) {
        s._knightOwners[ids[i]] = to;
      }
    }
  }
}