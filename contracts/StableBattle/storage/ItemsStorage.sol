// SPDX-License-Identifier: Unlicensed

pragma solidity ^0.8.0;

library ItemsStorage {
  struct State {
  //Original ERC1155 State
    // Mapping from token ID to account balances
    mapping(uint256 => mapping(address => uint256)) _balances;

    // Mapping from account to operator approvals
    mapping(address => mapping(address => bool)) _operatorApprovals;

    // Used as the URI for all token types by relying on ID substitution, e.g. https://token-cdn-domain/{id}.json
    string _uri;

  //ERC1155Supply Addition
    // Total amount of tokens in with a given id.
    mapping(uint256 => uint256) _totalSupply;
    
  //Items Facet Addition
    // Mapping from token ID to its owner
    mapping (uint256 => address) _knightOwners;
  }

  bytes32 internal constant STORAGE_SLOT = keccak256("Items.storage");

  function state() internal pure returns (State storage l) {
    bytes32 slot = STORAGE_SLOT;
    assembly {
      l.slot := slot
    }
  }
}

abstract contract ItemsGetters {
  function _balanceOf(address account, uint256 id) internal view virtual returns (uint256) {
    require(account != address(0), "ERC1155: address zero is not a valid owner");
    return ItemsStorage.state()._balances[id][account];
  }

  function _totalSupply(uint256 id) internal view virtual returns (uint256) {
      return ItemsStorage.state()._totalSupply[id];
  }
}

abstract contract ItemsModifiers {
  function ownsItem(uint256 itemId) internal view returns(bool) {
    return ItemsStorage.state()._balances[itemId][msg.sender] > 0;
  }
  modifier ifOwnsItem(uint256 itemId) {
    require(ownsItem(itemId),
    "ItemModifiers: You don't own this item");
    _;
  }
}