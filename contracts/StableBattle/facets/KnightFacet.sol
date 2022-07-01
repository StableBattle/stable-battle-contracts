// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.0;

import { ItemsFacet } from "./ItemsFacet.sol";
import { IKnight } from "../../shared/interfaces/IKnight.sol";

import { KnightStorage as KNHT, knightType, Knight} from "../storage/KnightStorage.sol";
import { MetaStorage as META} from "../storage/MetaStorage.sol";
import { ItemsStorage as ITEM } from "../storage/ItemsStorage.sol";

contract KnightFacet is ITEMFacet, IKnight {
  using KNHT for KNHT.Layout;
  using META for META.Layout;
  using ITEM for ITEM.Layout;

  function knightCheck(uint256 kinghtId) public view returns(Knight memory) {
    return KNHT.layout().knight[kinghtId];
  }

  function knightClan(uint256 kinghtId) public view returns(uint256) {
    return KNHT.layout().knight[kinghtId].inClan;
  }

  function knightClanOwnerOf(uint256 kinghtId) public view returns(uint256) {
    return KNHT.layout().knight[kinghtId].ownsClan;
  }

  function knightLevel(uint256 kinghtId) public view returns(uint) {
    return KNHT.layout().knight[kinghtId].level;
  }

  function knightTypeOf(uint256 kinghtId) public view returns(knightType) {
    return KNHT.layout().knight[kinghtId].kt;
  }

  function knightOwner(uint256 knightId) public view returns(address) {
    return KNHT.layout().kngiht[knightId].owner;
  }

  function randomKnightId() private view returns (uint256 knightId) {
    uint salt;
    do {
      salt++;
      knightId = uint256(keccak256(abi.encodePacked(block.timestamp, tx.origin, salt)));    
      if (knightId < KNHT.layout().knightOffset) {
        knightId += KNHT.layout().knightOffset;
      }
    } while (ITEM.layout()._totalSupply[knightId] != 0);
  }

  function knightPrice(knightType kt) external pure returns(uint256 price) {
    if (kt == knightType.AAVE) {
      price = 1e9;
    } else if (kt == knightType.OTHER) {
      price = 0;
    }
  }

  function mintKnight(knightType kt) external returns(uint256 id) {
    if (kt == knightType.AAVE) {
      // Check if user gave its approval for 1000 USDT
      require(META.layout().USDT.allowance(msg.sender, address(this)) >= 1e9, 
        "User allocated insufficient amount of funds");
      // Transfer 1000 USDT from user to contract
      META.layout().USDT.transferFrom(msg.sender, address(this), 1e9);
      // Supply 1000 USDT to AAVE
      META.layout().USDT.approve(address(META.layout().AAVE), 1e9);
      META.layout().AAVE.supply(address(META.layout().USDT), 1e9, address(this), 0);
    }
    // Mint NFT for the user
    id = randomKnightId();
    super._mint(msg.sender, id, 1, "");
    KNHT.layout().knight[id] = Knight(0, 0, 0, kt, msg.sender);

    emit KnightMinted(id, msg.sender, kt);
  }

  function burnKnight (uint256 id) external {
    //Check if item is knight
    require (id > KNHT.layout().knightOffset, "Item is not a knight");
    //Check if user owns NFT
    require (ITEM.layout()._balances[id][msg.sender] == 1, "User doesn't own this character");
    // Burn NFT
    super._burn(msg.sender, id, 1);
    // Withraw 1000 USDT from AAVE to the user
    if(KNHT.layout().knight[id].kt == knightType.AAVE) {
      META.layout().AAVE.withdraw(address(META.layout().USDT), 1e9, msg.sender);
      emit KnightBurned(id, msg.sender, knightType.AAVE);
    } else {
      emit KnightBurned(id, msg.sender, knightType.OTHER);
    }    
  }
}