// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.0;

import { ClanStorage as CLAN, Clan } from "../storage/ClanStorage.sol";
import { ItemsStorage as ITEM } from "../storage/ItemsStorage.sol";
import { KnightStorage as KNHT } from "../storage/KnightStorage.sol";
import { IClan } from "../../shared/interfaces/IClan.sol";

contract ClanFacet is IClan {
  using CLAN for CLAN.State;
  using KNHT for KNHT.State;

  function randomClanId() private view returns (uint clanId) {
    uint salt;
    do {
      salt++;
      clanId = uint(keccak256(abi.encodePacked(block.timestamp, tx.origin, salt)));
    } while (clanOwner(clanId) != 0);
  }
  
  function create(uint knightId) public returns (uint clanId) {
    require(knightId > KNHT.knightOffset(), "ClanFacet: Item is not a knight");
    require(ITEM.balanceOf(msg.sender, knightId) == 1,
            "ClanFacet: You don't own this knight");
    require(clanOwner(KNHT.knightClan(knightId)) == 0,
            "ClanFacet: Leave a clan before creating your own");
    require(KNHT.knightClanOwnerOf(knightId) == 0, "ClanFacet: Only one clan per knight");
    clanId = randomClanId();
    CLAN.state().clan[clanId] = Clan(knightId, 1, 0, 0);
    KNHT.state().knight[knightId].inClan = clanId;
    KNHT.state().knight[knightId].ownsClan = clanId;
    emit ClanCreated(clanId, knightId);
  }

  function dissolve(uint clanId) public {
    uint ownerId = clanOwner(clanId);
    require(ITEM.balanceOf(msg.sender, ownerId) == 1,
            "ClanFacet: A knight owning this clan doesn't belong to you");
    KNHT.state().knight[ownerId].ownsClan = 0;
    KNHT.state().knight[ownerId].inClan = 0;
    CLAN.state().clan[clanId].owner = 0;
    emit ClanDissloved(clanId, ownerId);
  }

  function onStake(address benefactor, uint clanId, uint amount) public {
    require(clanOwner(clanId) != 0, "ClanFacet: This clan doesn't exist");

    CLAN.state().stake[benefactor][clanId] += amount;
    CLAN.state().clan[clanId].stake += amount;
    leveling(clanId);

    emit StakeAdded(benefactor, clanId, amount);
  }

  function onWithdraw(address benefactor, uint clanId, uint amount) public {
    require(stakeOf(benefactor, clanId) >= amount, "ClanFacet: Not enough SBT staked");
    
    CLAN.state().stake[benefactor][clanId] -= amount;
    CLAN.state().clan[clanId].stake -= amount;
    leveling(clanId);

    emit StakeWithdrawn(benefactor, clanId, amount);
  }

  //Calculate clan level based on stake
  function leveling(uint clanId) private {
    uint newLevel = 0;
    while (clanStake(clanId) > clanLevelThresholds(newLevel) &&
           newLevel < clanMaxLevel()) {
      newLevel++;
    }
    if (clanLevel(clanId) < newLevel) {
      CLAN.state().clan[clanId].level = newLevel;
      emit ClanLeveledUp (clanId, newLevel);
    } else if (clanLevel(clanId) > newLevel) {
      CLAN.state().clan[clanId].level = newLevel;
      emit ClanLeveledDown (clanId, newLevel);
    }
  }

  function join(uint knightId, uint clanId) public {
    require(knightId > KNHT.knightOffset(),
      "ClanFacet: Item is not a knight");
    require(ITEM.balanceOf(msg.sender, knightId) == 1,
      "ClanFacet: You don't own this knight");
    require(clanOwner(KNHT.knightClan(knightId)) == 0,
      "ClanFacet: Leave your old clan before joining a new one");
    
    CLAN.state().joinProposal[knightId] = clanId;
    emit KnightAskedToJoin(clanId, knightId);
  }

  function acceptJoin(uint256 knightId, uint256 clanId) public {
    require(ITEM.balanceOf(msg.sender, clanOwner(clanId)) == 1,
            "ClanFacet: A knight owning this clan doesn't belong to you");
    require(joinProposal(knightId) == clanId,
            "ClanFacet: This knight didn't offer to join your clan");

    CLAN.state().clan[clanId].totalMembers++;
    KNHT.state().knight[knightId].inClan = clanId;
    CLAN.state().joinProposal[knightId] = 0;

    emit KnightJoinedClan(clanId, knightId);
  }

  function refuseJoin(uint256 knightId, uint256 clanId) public {
    require(ITEM.balanceOf(msg.sender, clanOwner(clanId)) == 1,
            "ClanFacet: A knight owning this clan doesn't belong to you");
    require(joinProposal(knightId) == clanId,
            "ClanFacet: This knight didn't offer to join your clan");
    
    CLAN.state().joinProposal[knightId] = 0;

    emit JoinProposalRefused(clanId, knightId);
  }

  function leave(uint256 knightId, uint256 clanId) public {
    require(ITEM.balanceOf(msg.sender, knightId) == 1,
      "ClanFacet: This knight doesn't belong to you");
    require(KNHT.knightClan(knightId) == clanId, 
      "ClanFacet: Your knight doesn't belong to this clan");
    require(clanOwner(clanId) != knightId,
      "ClanFacet: You can't leave your own clan");

    CLAN.state().leaveProposal[knightId] = clanId;
    
    emit KnightAskedToLeave(clanId, knightId);
  }

  function acceptLeave(uint256 knightId, uint256 clanId) public {
    require(ITEM.balanceOf(msg.sender, clanOwner(clanId)) == 1,
            "ClanFacet: A knight owning this clan doesn't belong to you");
    require(leaveProposal(knightId) == clanId,
            "ClanFacet: This knight didn't offer to leave your clan");

    CLAN.state().clan[clanId].totalMembers--;
    KNHT.state().knight[knightId].inClan = 0;
    CLAN.state().leaveProposal[knightId] = 0;

    emit KnightLeavedClan(clanId, knightId);
  }

  function refuseLeave(uint256 knightId, uint256 clanId) public {
    require(ITEM.balanceOf(msg.sender, clanOwner(clanId)) == 1,
            "ClanFacet: A knight owning this clan doesn't belong to you");
    require(leaveProposal(knightId) == clanId,
            "ClanFacet: This knight didn't offer to leave your clan");
    
    CLAN.state().leaveProposal[knightId] = 0;

    emit LeaveProposalRefused(clanId, knightId);
  }

  function clanCheck(uint clanId) public view returns(Clan memory) {
    return CLAN.clanCheck(clanId);
  }

  function clanOwner(uint clanId) public view returns(uint256) {
    return CLAN.clanOwner(clanId);
  }

  function clanTotalMembers(uint clanId) public view returns(uint) {
    return CLAN.clanTotalMembers(clanId);
  }
  
  function clanStake(uint clanId) public view returns(uint) {
    return CLAN.clanStake(clanId);
  }

  function clanLevel(uint clanId) public view returns(uint) {
    return CLAN.clanLevel(clanId);
  }

  function stakeOf(address benefactor, uint clanId) public view returns(uint256) {
    return CLAN.stakeOf(benefactor, clanId);
  }

  function clanLevelThresholds(uint newLevel) public view returns (uint) {
    return CLAN.clanLevelThresholds(newLevel);
  }

  function clanMaxLevel() public view returns (uint) {
    return CLAN.clanMaxLevel();
  }

  function joinProposal(uint256 knightId) public view returns (uint) {
    return CLAN.joinProposal(knightId);
  }

  function leaveProposal(uint256 knightId) public view returns (uint) {
    return CLAN.leaveProposal(knightId);
  }
}
