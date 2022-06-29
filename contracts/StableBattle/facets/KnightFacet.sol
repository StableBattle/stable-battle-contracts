// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.0;

//import { Knight, knightType } from "../libraries/LibAppStorage.sol";
import { IKnight } from "../../shared/interfaces/IKnight.sol";
import { KnightStorage as Ks, knightType, Knight} from "../storage/KnightStorage.sol";
import { MetaStorage as Ms} from "../storage/MetaStorage.sol";
import { ItemsFacet } from "./ItemsFacet.sol";
import { ERC1155Storage } from "../storage/ERC1155Storage.sol";
import { ERC1155SupplyStorage } from "../storage/ERC1155SupplyStorage.sol";

contract KnightFacet is ItemsFacet, IKnight {
  using Ks for Ks.Layout;
  using Ms for Ms.Layout;
  using ERC1155Storage for ERC1155Storage.Layout;
  using ERC1155SupplyStorage for ERC1155SupplyStorage.Layout;

  function knightCheck(uint256 kinghtId) public view returns(Knight memory) {
    return Ks.layout().knight[kinghtId];
  }

  function knightClan(uint256 kinghtId) public view returns(uint256) {
    return Ks.layout().knight[kinghtId].inClan;
  }

  function knightClanOwnerOf(uint256 kinghtId) public view returns(uint256) {
    return Ks.layout().knight[kinghtId].ownsClan;
  }

  function knightLevel(uint256 kinghtId) public view returns(uint) {
    return Ks.layout().knight[kinghtId].level;
  }

  function knightTypeOf(uint256 kinghtId) public view returns(knightType) {
    return Ks.layout().knight[kinghtId].kt;
  }

  function randomKnightId() private view returns (uint256 knightId) {
    uint salt;
    do {
      salt++;
      knightId = uint256(keccak256(abi.encodePacked(block.timestamp, tx.origin, salt)));    
      if (knightId < Ks.layout().knightOffset) {
        knightId += Ks.layout().knightOffset;
      }
    } while (ERC1155SupplyStorage.layout()._totalSupply[knightId] != 0);
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
      require(Ms.layout().USDT.allowance(msg.sender, address(this)) >= 1e9, 
        "User allocated insufficient amount of funds");
      // Transfer 1000 USDT from user to contract
      Ms.layout().USDT.transferFrom(msg.sender, address(this), 1e9);
      // Supply 1000 USDT to AAVE
      Ms.layout().USDT.approve(address(Ms.layout().AAVE), 1e9);
      Ms.layout().AAVE.supply(address(Ms.layout().USDT), 1e9, address(this), 0);
    }
    if (kt == knightType.OTHER) {}
    // Mint NFT for the user
    id = randomKnightId();
    super._mint(msg.sender, id, 1, "");
    Ks.layout().knight[id] = Knight(0, 0, 0, kt);

    emit KnightMinted(id, msg.sender, kt);
  }

  function burnKnight (uint256 id) external {
    //Check if item is knight
    require (id > Ks.layout().knightOffset, "Item is not a knight");
    //Check if user owns NFT
    require (ERC1155Storage.layout()._balances[id][msg.sender] == 1, "User doesn't own this character");
    // Burn NFT
    super._burn(msg.sender, id, 1);
    // Withraw 1000 USDT from AAVE to the user
    if(Ks.layout().knight[id].kt == knightType.AAVE) {
      Ms.layout().AAVE.withdraw(address(Ms.layout().USDT), 1e9, msg.sender);
      emit KnightBurned(id, msg.sender, knightType.AAVE);
    } else {
      emit KnightBurned(id, msg.sender, knightType.OTHER);
    }    
  }
}