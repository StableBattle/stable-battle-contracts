// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.10;

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { IPool } from "@aave/core-v3/contracts/interfaces/IPool.sol";
import { ISBT } from "../../shared/interfaces/ISBT.sol";
import { IERC721Enumerable } from "../../shared/interfaces/IERC721Enumerable.sol";
import { IItems } from "../../shared/interfaces/IItems.sol";

enum knightType {
  AAVE,
  OTHER
}

struct Clan {
  uint owner;
  uint total_members;
  uint stake;
  uint level;
}

struct Knight {
  uint256 inClan;
  uint256 ownsClan;
  uint level;
  knightType kt;
}

struct AppStorage {
  address[] ItemForges;
  // StableBattle EIP20 Token address
  ISBT SBT;
  // StableBattle EIP721 Village address
  IERC721Enumerable SBV;

  IERC20 USDT;
  IPool AAVE;

  IItems Items;

  //Knight facet
    uint256 knight_offset;
    mapping(uint256 => Knight) knight;

  //ERC1155 Facet
    // Mapping from token ID to account balances
    mapping(uint256 => mapping(address => uint256)) _balances;

    // Mapping from account to operator approvals
    mapping(address => mapping(address => bool)) _operatorApprovals;

    // Used as the URI for all token types by relying on ID substitution, e.g. https://token-cdn-domain/{id}.json
    string _uri;

    // Total amount of tokens in with a given id.
    mapping(uint256 => uint256) _totalSupply;

  //Item Facet
    // Mapping from token ID to its owner
    mapping (uint256 => address) _knightOwners;

  //Clan Facet
    uint MAX_CLAN_MEMBERS;
    uint[] levelThresholds;
    // clan_id => clan
    mapping(uint => Clan) clan;
    // character_id => clan_id
    mapping (uint => uint) join_proposal;
    // character_id => clan_id
    mapping (uint => uint) leave_proposal;
    // address => clan_id => amount
    mapping (address => mapping (uint => uint)) stake;

  //Treasury Facet
    uint castle_tax;
    uint villageAmount;
    address[] beneficiaries;
    uint last_block;
    uint reward_per_block;

  //Tournament Facet
    uint CastleHolder;
}