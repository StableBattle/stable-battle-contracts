// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.0;

import { ItemsFacet } from "./ItemsFacet.sol";
import { IForge } from "../../shared/interfaces/IForge.sol";

import { KnightStorage as KNHT} from "../storage/KnightStorage.sol";

contract ForgeFacet is ItemsFacet, IForge {

  function mintItem (uint id, uint amount) public {
    require(id < KNHT.layout().knightOffset, 
      "ForgeFacet: knight are only  mintable through KnightFacet");
    super._mint(msg.sender, id, amount, "");
  }

  function burnItem (uint id, uint amount) public {
    require(id < KNHT.layout().knightOffset, 
      "ForgeFacet: knight are only burnable through KnightFacet");
    require (balanceOf(msg.sender, id) >= amount, 
      "Insufficient amount of items to burn");
    super._burn(msg.sender, id, amount);
  }
}