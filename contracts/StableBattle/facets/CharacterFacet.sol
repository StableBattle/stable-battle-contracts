// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.0;
import { IERC1155 } from "../interfaces/IERC1155.sol";

contract CharacterFacet {
  uint item_id = 1;
// Mint NFT for 1000 USDT
  function mint_character () public {
  // Check if user gave its approval for 1000 USDT
  require(USDT.allowance(msg.sender, address(this)) >= 1e9, 
    "User allocated insufficient amount of funds");
  console.log("Sender allocated %d USDT to the contract tokens", 
              USDT.allowance(msg.sender, address(this))/1e6);
  // Transfer 1000 USDT from user to contract
  USDT.transferFrom(msg.sender, address(this), 1e9);
  console.log("%d USDT on this contract",
              USDT.balanceOf(address(this))/1e6);
  // Supply 1000 USDT to AAVE
  USDT.approve(address(AAVE), 1e9);
  AAVE.supply(address(USDT), 1e9, address(this), 0);
  // Mint NFT for the user
  ERC721._mint(msg.sender, tid);
  item_id += 1;
  }

// Burn NFT and repay 1000 USDT back
  function burn_character (uint256 TokenId) public {
  //Check if user owns NFT
  require (ERC721.ownerOf(TokenId) == msg.sender);
  // Burn NFT
  ERC721._burn(TokenId);
  // Withraw 1000 USDT from AAVE to the user
  AAVE.withdraw(address(USDT), 1e9, msg.sender);
  }

  event CharacterMinted (uint charater_id, address user);
  event CharaterBurned (uint character_id, address user);
}