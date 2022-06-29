// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.0;

import { ItemsFacet } from "./ItemsFacet.sol";
import "../../shared/interfaces/IForge.sol";

contract ForgeFacet is ItemsFacet, IForge {

  function mintItem (uint id, uint amount) public {
    super._mint(msg.sender, id, amount, "");
  }

  function burnItem (uint id, uint amount) public {
    require (super.balanceOf(msg.sender, id) >= amount, 
      "Insufficient amount of items to burn");
    super._burn(msg.sender, id, amount);
  }
}