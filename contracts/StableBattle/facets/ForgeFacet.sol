// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.0;

import { AppStorage } from "../libraries/LibAppStorage.sol";

contract ForgeFacet {

  AppStorage internal s;

  function mintItem (uint item_id, uint amount) public {
    s.Items.mint(msg.sender, item_id, amount);
  }

  function burnItem (uint item_id, uint amount) public {
    require (s.Items.balanceOf(msg.sender, item_id) >= amount, "Insufficient amount of items to burn");
    s.Items.burn(msg.sender, item_id, amount);
  }
}