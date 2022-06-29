// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.0;

import { IClan } from "../../shared/interfaces/IClan.sol";

struct AppStorage {
  //ERC20
    string _name;
    string _symbol;
    uint8 _decimals;

    mapping(address => uint256) _balances;

    mapping(address => mapping(address => uint256)) _allowances;

    uint256 _totalSupply;
  //SBT Facet
    address SBD;

    IClan ClanFacet;
}