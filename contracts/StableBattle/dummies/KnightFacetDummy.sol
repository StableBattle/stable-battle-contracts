// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.0;

import { ItemsFacetDummy } from "./ItemsFacetDummy.sol";
import { IKnight } from "../../shared/interfaces/IKnight.sol";

import { knightType, Knight} from "../storage/KnightStorage.sol";

contract KnightFacetDummy is ItemsFacetDummy, IKnight {

  function knightCheck(uint256 kinghtId) public view returns(Knight memory) {}

  function knightClan(uint256 kinghtId) public view returns(uint256) {}

  function knightClanOwnerOf(uint256 kinghtId) public view returns(uint256) {}

  function knightLevel(uint256 kinghtId) public view returns(uint) {}

  function knightTypeOf(uint256 kinghtId) public view returns(knightType) {}

  function knightOwner(uint256 knightId) public view returns(address) {}

  function knightPrice(knightType kt) external pure returns(uint256 price) {}

  function mintKnight(knightType kt) external returns(uint256 id) {}

  function burnKnight (uint256 id) external {}
}