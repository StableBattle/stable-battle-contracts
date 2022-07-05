// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.0;

import { IForge } from "../../shared/interfaces/IForge.sol";
import { ItemsFacetDummy } from "./ItemsFacetDummy.sol";

contract ForgeFacetDummy is ItemsFacetDummy, IForge {

  function mintItem (uint id, uint amount) public {}

  function burnItem (uint id, uint amount) public {}
}