// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.0;

import { ItemsFacet } from "./ItemsFacet.sol";
import { IKnight } from "../../shared/interfaces/IKnight.sol";
import { IClan } from "../../shared/interfaces/IClan.sol";

import { KnightStorage as KNHT, knightType, Knight, KnightGetters, KnightModifiers} from "../storage/KnightStorage.sol";
import { ExternalCalls } from "../storage/MetaStorage.sol";
import { ItemsStorage as ITEM, ItemsModifiers } from "../storage/ItemsStorage.sol";
import { ClanStorage as CLAN } from "../storage/ClanStorage.sol";

contract KnightFacet is ItemsFacet, 
                        IKnight, 
                        KnightGetters, 
                        KnightModifiers, 
                        ExternalCalls, 
                        ItemsModifiers {
  using KNHT for KNHT.State;
  using CLAN for CLAN.State;

  function mintKnight(knightType kt) external {
    require(kt != knightType.NONE,
      "KnightFacet: Can only mint knights of valid knightType's");
    if (kt == knightType.AAVE) {
      // Check if user gave its approval for 1000 USDT
      require(USDT().allowance(msg.sender, address(this)) >= knightPrice(knightType.AAVE), 
        "KnightFacet: User allocated insufficient amount of funds");
      // Transfer 1000 USDT from user to contract
      USDT().transferFrom(msg.sender, address(this), knightPrice(knightType.AAVE));
      // Supply 1000 USDT to AAVE
      USDT().approve(address(AAVE()), knightPrice(knightType.AAVE));
      AAVE().supply(address(USDT()), knightPrice(knightType.AAVE), address(this), 0);
    }
    // Mint NFT for the user
    uint256 knightId = type(uint256).max - knightsMinted();
    _mint(msg.sender, knightId, 1, "");
    KNHT.state().knightsMinted[kt]++;
    //Initialize Knight
    KNHT.state().knight[knightId] = Knight(0, 0, 0, kt, msg.sender);

    emit KnightMinted(knightId, msg.sender, kt);
  }

  function burnKnight (uint256 knightId)
    external
    ifIsKnight(knightId)
    ifOwnsItem(knightId)
  {
    knightType kt = knightTypeOf(knightId);
  /*
    uint256 ownerId = knightClanOwnerOf(knightId);
    uint256 clanId = knightClan(knightId);
    //Dissolve knight's clan and/or kick him out
    if (ownerId != 0) {
    //Copy of disslove(uint256) from ClanFacet
    //Should think of a better way to do this
    //Maybe worth a CALL
      KNHT.state().knight[ownerId].ownsClan = 0;
      KNHT.state().knight[ownerId].inClan = 0;
      CLAN.state().clan[clanId].owner = 0;
      emit IClan.ClanDissloved(clanId, ownerId, true);
    }
    if (clanId != 0) {
    //Copy of acceptLeave() from ClanFacet
    //Should think of a better way to do this
    //Maybe worth a CALL
      CLAN.state().clan[clanId].totalMembers--;
      KNHT.state().knight[knightId].inClan = 0;
      CLAN.state().leaveProposal[knightId] = 0;
      emit IClan.KnightLeavedClan(clanId, knightId, true);
    }
  */
    // Null the knight
    KNHT.state().knight[knightId] = Knight(0, 0, 0, knightType.NONE, address(0));
    // Burn NFT
    _burn(msg.sender, knightId, 1);
    KNHT.state().knightsBurned[kt]++;
    // Withraw 1000 USDT from AAVE to the user
    if(kt == knightType.AAVE) {
      AAVE().withdraw(address(USDT()), knightPrice(knightType.AAVE), msg.sender);
    }
    emit KnightBurned(knightId, msg.sender, kt);
  }

//Public Getters

  function getKnightCheck(uint256 knightId) public view returns(Knight memory) {
    return knightCheck(knightId);
  }

  function getKnightClan(uint256 knightId) public view returns(uint256) {
    return knightClan(knightId);
  }

  function getKnightClanOwnerOf(uint256 knightId) public view returns(uint256) {
    return knightClanOwnerOf(knightId);
  }

  function getKnightLevel(uint256 knightId) public view returns(uint) {
    return knightLevel(knightId);
  }

  function getKnightTypeOf(uint256 knightId) public view returns(knightType) {
    return knightTypeOf(knightId);
  }

  function getKnightOwner(uint256 knightId) public view returns(address) {
    return knightOwner(knightId);
  }

  function getKnightPrice(knightType kt) public view returns (uint256) {
    return knightPrice(kt);
  }

  function getKnightsMinted(knightType kt) public view returns (uint256) {
    return knightsMinted(kt);
  }

  function getKnightsBurned(knightType kt) public view returns (uint256) {
    return knightsBurned(kt);
  }

  function getTotalKnightSupply(knightType kt) public view returns (uint256) {
    return totalKnightSupply(kt);
  }

  function getKnightsMinted() public view returns (uint256 knightsMintedTotal) {
    return knightsMinted();
  }

  function getKnightsBurned() public view returns (uint256 knightsBurnedTotal) {
    return knightsBurned();
  }

  function getTotalKnightSupply() public view returns (uint256) {
    return totalKnightSupply();
  }
}