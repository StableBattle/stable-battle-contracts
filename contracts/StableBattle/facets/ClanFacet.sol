// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.0;

import { ClanStorage as CLAN, Clan, ClanGetters, ClanModifiers, proposalType } from "../storage/ClanStorage.sol";
import { ItemsModifiers, ItemsGetters } from "../storage/ItemsStorage.sol";
import { KnightStorage as KNHT, KnightModifiers } from "../storage/KnightStorage.sol";
import { MetaModifiers } from "../storage/MetaStorage.sol";
import { IClan } from "../../shared/interfaces/IClan.sol";

contract ClanFacet is IClan, 
                      ClanGetters, 
                      KnightModifiers, 
                      ItemsModifiers, 
                      ItemsGetters, 
                      ClanModifiers,
                      MetaModifiers
{
  using CLAN for CLAN.State;
  using KNHT for KNHT.State;

//Creation and Dissolution of a clan
  function create(uint256 knightId) public ifIsKnight(knightId) ifOwnsItem(knightId) returns (uint clanId) {
    require(clanOwner(knightClan(knightId)) == 0,
            "ClanFacet: Leave a clan before creating your own");
    require(knightClanOwnerOf(knightId) == 0, "ClanFacet: Only one clan per knight");
    clanId = clansInTotal() + 1;
    CLAN.state().clan[clanId] = Clan(knightId, 0, 1, 0);
    KNHT.state().knight[knightId].inClan = clanId;
    KNHT.state().knight[knightId].ownsClan = clanId;
    CLAN.state().clansInTotal++;
    emit ClanCreated(clanId, knightId);
  }

  function dissolve(uint256 clanId) 
    public 
    ifOwnsItem(clanOwner(clanId))
  {
    uint256 ownerId = clanOwner(clanId);
    KNHT.state().knight[ownerId].ownsClan = 0;
    KNHT.state().knight[ownerId].inClan = 0;
    CLAN.state().clan[clanId].owner = 0;
    emit ClanDissloved(clanId, ownerId, false);
  }

// Clan stakes and leveling
  function onStake(address benefactor, uint256 clanId, uint256 amount)
    external
    //onlySBT
    ifClanExists(clanId)
  {
    CLAN.state().stake[benefactor][clanId] += amount;
    CLAN.state().clan[clanId].stake += amount;
    leveling(clanId);

    emit StakeAdded(benefactor, clanId, amount);
  }

  function onWithdraw(address benefactor, uint256 clanId, uint256 amount)
    external
    //onlySBT
    ifClanExists(clanId)
  {
    require(stakeOf(benefactor, clanId) >= amount, "ClanFacet: Not enough SBT staked");
    
    CLAN.state().stake[benefactor][clanId] -= amount;
    CLAN.state().clan[clanId].stake -= amount;
    leveling(clanId);

    emit StakeWithdrawn(benefactor, clanId, amount);
  }

  //Calculate clan level based on stake
  function leveling(uint256 clanId) private {
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

//Join, Leave and Invite Proposals
  function join(uint256 knightId, uint256 clanId)
    public
    ifIsKnight(knightId)
    ifOwnsItem(knightId)
    ifClanExists(clanId)
  {
    require(clanOwner(knightClan(knightId)) == 0,
      "ClanFacet: Leave your old clan before joining a new one");
    
    CLAN.state().joinProposal[knightId] = clanId;
    emit KnightAskedToJoin(clanId, knightId);
  }

  function acceptJoin(uint256 knightId, uint256 clanId)
    public
    ifClanExists(clanId)
    ifIsKnight(knightId)
    ifOwnsItem(clanOwner(clanId))
  {
    require(joinProposal(knightId) == clanId,
            "ClanFacet: This knight didn't offer to join your clan");

    CLAN.state().clan[clanId].totalMembers++;
    KNHT.state().knight[knightId].inClan = clanId;
    CLAN.state().joinProposal[knightId] = 0;

    emit KnightJoinedClan(clanId, knightId);
  }

  function refuseJoin(uint256 knightId, uint256 clanId)
    public
    ifClanExists(clanId)
    ifIsKnight(knightId)
    ifOwnsItem(clanOwner(clanId))
  {
    require(joinProposal(knightId) == clanId,
            "ClanFacet: This knight didn't offer to join your clan");
    
    CLAN.state().joinProposal[knightId] = 0;

    emit JoinProposalRefused(clanId, knightId);
  }

  function leave(uint256 knightId, uint256 clanId) 
    public
    ifClanExists(clanId)
    ifIsKnight(knightId)
  {
    require(knightClan(knightId) == clanId, 
      "ClanFacet: Your knight doesn't belong to this clan");
    require(clanOwner(clanId) != knightId,
      "ClanFacet: You can't leave your own clan");

    CLAN.state().leaveProposal[knightId] = clanId;
    
    emit KnightAskedToLeave(clanId, knightId);
  }

  function acceptLeave(uint256 knightId, uint256 clanId)
    public
    ifClanExists(clanId)
    ifIsKnight(knightId)
    ifOwnsItem(clanOwner(clanId))
  {
    require(leaveProposal(knightId) == clanId,
            "ClanFacet: This knight didn't offer to leave your clan");

    CLAN.state().clan[clanId].totalMembers--;
    KNHT.state().knight[knightId].inClan = 0;
    CLAN.state().leaveProposal[knightId] = 0;

    emit KnightLeavedClan(clanId, knightId, false);
  }

  function refuseLeave(uint256 knightId, uint256 clanId)
    public
    ifClanExists(clanId)
    ifIsKnight(knightId)
    ifOwnsItem(clanOwner(clanId))
  {
    require(leaveProposal(knightId) == clanId,
            "ClanFacet: This knight didn't offer to leave your clan");
    
    CLAN.state().leaveProposal[knightId] = 0;

    emit LeaveProposalRefused(clanId, knightId);
  }

//Public getters

  function getClanOwner(uint clanId) public view returns(uint256) {
    return clanOwner(clanId);
  }

  function getClanTotalMembers(uint clanId) public view returns(uint) {
    return clanTotalMembers(clanId);
  }
  
  function getClanStake(uint clanId) public view returns(uint256) {
    return clanStake(clanId);
  }

  function getClanLevel(uint clanId) public view returns(uint) {
    return clanLevel(clanId);
  }

  function getStakeOf(address benefactor, uint clanId) public view returns(uint256) {
    return stakeOf(benefactor, clanId);
  }

  function getClanLevelThresholds(uint newLevel) public view returns (uint) {
    return clanLevelThresholds(newLevel);
  }

  function getClanMaxLevel() public view returns (uint) {
    return clanMaxLevel();
  }

  function getJoinProposal(uint256 knightId) public view returns (uint) {
    return joinProposal(knightId);
  }

  function getLeaveProposal(uint256 knightId) public view returns (uint) {
    return leaveProposal(knightId);
  }
}
