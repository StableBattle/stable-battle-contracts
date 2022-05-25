// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.10;
import { ERC1155 } from "./ERC1155Facet.sol";
import {Knight} from "../libraries/LibAppStorage.sol";

abstract contract KnightFacet is ERC1155 {

  // Mint NFT for 1000 USDT
  function mint_knight() public {
    // Check if user gave its approval for 1000 USDT
    require(s.USDT.allowance(msg.sender, address(this)) >= 1e9, 
      "User allocated insufficient amount of funds");
    //console.log("Sender allocated %d USDT to the contract tokens", 
    //            s.USDT.allowance(msg.sender, address(this))/1e6);
    // Transfer 1000 USDT from user to contract
    s.USDT.transferFrom(msg.sender, address(this), 1e9);
    //console.log("%d USDT on this contract",
    //            s.USDT.balanceOf(address(this))/1e6);
    // Supply 1000 USDT to AAVE
    s.USDT.approve(address(s.AAVE), 1e9);
    s.AAVE.supply(address(s.USDT), 1e9, address(this), 0);
    // Mint NFT for the user
    _mint(msg.sender, s.item_id, 1, '');
    s.knight[s.item_id] = Knight(0, 0, 0);
    s.item_id++;

    emit KnightMinted (s.item_id, msg.sender);
  }

// Burn NFT and repay 1000 USDT back
  function burn_knight (uint256 item_id) public {
    //Check if item is knight
    require (item_id < s.item_offset, "Item is not a knight");
    //Check if user owns NFT
    require (balanceOf(msg.sender, item_id) == 1, "User doesn't own this character");
    // Burn NFT
    _burn(msg.sender, item_id, 1);
    // Withraw 1000 USDT from AAVE to the user
    s.AAVE.withdraw(address(s.USDT), 1e9, msg.sender);

    emit KnightBurned (item_id, msg.sender);
  }

  event KnightMinted (uint charater_id, address user);
  event KnightBurned (uint character_id, address user);
}