// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.10;

import { IClan } from "../../shared/interfaces/IClan.sol";

struct AppStorage {
  // Token name
  string _name;

  // Token symbol
  string _symbol;

  // Mapping from token ID to owner address
  mapping(uint256 => address) _owners;

  // Mapping owner address to token count
  mapping(address => uint256) _balances;

  // Mapping from token ID to approved address
  mapping(uint256 => address) _tokenApprovals;

  // Mapping from owner to operator approvals
  mapping(address => mapping(address => bool)) _operatorApprovals;
  
  // Mapping from owner to list of owned token IDs
  mapping(address => mapping(uint256 => uint256)) _ownedTokens;

  // Mapping from token ID to index of the owner tokens list
  mapping(uint256 => uint256) _ownedTokensIndex;

  // Array with all token ids, used for enumeration
  uint256[] _allTokens;

  // Mapping from token id to position in the allTokens array
  mapping(uint256 => uint256) _allTokensIndex;
}