// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.0;

import { Knight, knightType, AppStorage } from "../libraries/LibAppStorage.sol";
import { IKnight } from "../../shared/interfaces/IKnight.sol";

contract KnightFacet is IKnight {

  AppStorage internal s;

  function randomKnightId() private view returns (uint256 item_id) {
    uint salt;
    do {
      salt++;
      item_id = uint(keccak256(abi.encodePacked(block.timestamp, tx.origin, salt)));    
      if (item_id < s.knight_offset) {
        item_id += s.knight_offset;
      }
    } while (s._totalSupply[item_id] != 0);
  }

  function knightPrice() external pure returns(uint256 price) {
    //if (kt == knightType.AAVE) {
      price = 1e9;
    //} else if (kt == knightType.OTHER) {
    //  price = 0;
    //}
  }

  function mint_AAVE_knight() external returns(uint256 id) {
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
    id = randomKnightId();
    s.Items.mint(msg.sender, id, 1);
    s.knight[id] = Knight(0, 0, 0, knightType.AAVE);

    emit KnightMinted(id, msg.sender, knightType.AAVE);
  }

  function mint_OTHER_knight() external returns(uint256 id) {
    // Mint NFT for the user
    id = randomKnightId();
    s.Items.mint(msg.sender, id, 1);
    s.knight[id] = Knight(0, 0, 0, knightType.OTHER);

    emit KnightMinted(id, msg.sender, knightType.OTHER);
  }

  function burn_knight (uint256 id) external {
    //Check if item is knight
    require (id > s.knight_offset, "Item is not a knight");
    //Check if user owns NFT
    require (s._balances[id][msg.sender] == 1, "User doesn't own this character");
    // Burn NFT
    s.Items.burn(msg.sender, id, 1);
    // Withraw 1000 USDT from AAVE to the user
    if(s.knight[id].kt == knightType.AAVE) {
      s.AAVE.withdraw(address(s.USDT), 1e9, msg.sender);
      emit KnightBurned(id, msg.sender, knightType.AAVE);
    } else {
      emit KnightBurned(id, msg.sender, knightType.OTHER);
    }

    
  }
}