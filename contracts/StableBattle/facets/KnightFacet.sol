// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.0;

import { ItemsFacet } from "./ItemsFacet.sol";
import { IKnight } from "../../shared/interfaces/IKnight.sol";

import { KnightStorage as KNHT, knightType, Knight} from "../storage/KnightStorage.sol";
import { MetaStorage as META} from "../storage/MetaStorage.sol";
import { ItemsStorage as ITEM } from "../storage/ItemsStorage.sol";

contract KnightFacet is ItemsFacet, IKnight {
  using KNHT for KNHT.Layout;

  function mintKnight(knightType kt) external returns(uint256 id) {
    if (kt == knightType.AAVE) {
      // Check if user gave its approval for 1000 USDT
      require(META.USDT().allowance(msg.sender, address(this)) >= knightPrice(knightType.AAVE), 
        "KnightFacet: User allocated insufficient amount of funds");
      // Transfer 1000 USDT from user to contract
      META.USDT().transferFrom(msg.sender, address(this), knightPrice(knightType.AAVE));
      // Supply 1000 USDT to AAVE
      META.USDT().approve(address(META.AAVE()), knightPrice(knightType.AAVE));
      META.AAVE().supply(address(META.USDT()), knightPrice(knightType.AAVE), address(this), 0);
    }
    // Mint NFT for the user
    id = randomKnightId();
    _mint(msg.sender, id, 1, "");
    KNHT.layout().knight[id] = Knight(0, 0, 0, kt, msg.sender);

    emit KnightMinted(id, msg.sender, kt);
  }

  function burnKnight (uint256 id) external {
    //Check if item is knight
    require (id >= knightOffset(), "KnightFacet: Item is not a knight");
    //Check if user owns NFT
    require (ITEM.balanceOf(msg.sender, id) == 1, "KnightFacet: User doesn't own this character");
    // Burn NFT
    _burn(msg.sender, id, 1);
    // Withraw 1000 USDT from AAVE to the user
    knightType kt = KNHT.knightTypeOf(id);
    if(kt == knightType.AAVE) {
      META.AAVE().withdraw(address(META.USDT()), knightPrice(knightType.AAVE), msg.sender);
    }
    emit KnightBurned(id, msg.sender, kt);
  }

  function randomKnightId() private view returns (uint256 knightId) {
    uint salt;
    do {
      salt++;
      knightId = uint256(keccak256(abi.encodePacked(block.timestamp, tx.origin, salt)));    
      if (knightId < knightOffset()) {
        knightId += knightOffset();
      }
    } while (ITEM.totalSupply(knightId) != 0);
  }

  function knightPrice(knightType kt) public pure returns(uint256 price) {
    if (kt == knightType.AAVE) {
      price = 1e9;
    } else if (kt == knightType.OTHER) {
      price = 0;
    }
  }

  function knightCheck(uint256 knightId) public view returns(Knight memory) {
    return KNHT.knightCheck(knightId);
  }

  function knightClan(uint256 knightId) public view returns(uint256) {
    return KNHT.knightClan(knightId);
  }

  function knightClanOwnerOf(uint256 knightId) public view returns(uint256) {
    return KNHT.knightClanOwnerOf(knightId);
  }

  function knightLevel(uint256 knightId) public view returns(uint) {
    return KNHT.knightLevel(knightId);
  }

  function knightTypeOf(uint256 knightId) public view returns(knightType) {
    return KNHT.knightTypeOf(knightId);
  }

  function knightOwner(uint256 knightId) public view returns(address) {
    return KNHT.knightOwner(knightId);
  }

  function knightOffset() internal view returns(uint256) {
    return KNHT.knightOffset();
  }
}