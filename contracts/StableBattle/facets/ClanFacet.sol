// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.0;

import { ClanStorage as CLAN, Clan, Proposal, ClanGetters, ClanModifiers } from "../storage/ClanStorage.sol";
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

//Creation, Abandonment and Leader Change
  function create(uint256 knightId)
    public
    ifIsKnight(knightId)
  //ifOwnsItem(knightId)
    ifNotInClan(knightId)
    returns(uint clanId)
  {
    clanId = clansInTotal() + 1;
    CLAN.state().clan[clanId] = Clan(knightId, 0, 1, 0);
    KNHT.state().knight[knightId].inClan = clanId;
    CLAN.state().clansInTotal++;
    emit ClanCreated(clanId, knightId);
  }

  function abandon(uint256 clanId) 
    public 
    ifOwnsItem(clanLeader(clanId))
  {
    require(ownsItem(clanLeader(clanId)) || isSBD(), 
      "ClanFacet: you don't lead this clan");
    uint256 leaderId = clanLeader(clanId);
    KNHT.state().knight[leaderId].inClan = 0;
    CLAN.state().clan[clanId].leader = 0;
    emit ClanAbandoned(clanId, leaderId);
  }

  function changeLeader(uint256 clanId, uint256 knightId)
    public
    ifIsKnight(knightId)
    ifIsInClan(knightId, clanId)
  //ifOwnsItem(clanLeader(clanId))
    ifIsNotClanLeader(knightId, clanId)
  {
    CLAN.state().clan[clanId].leader = knightId;
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
    while (clanStake(clanId) > clanLevelThreshold(newLevel) &&
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
  //ONLY knight supposed call the join function
  function join(uint256 knightId, uint256 clanId)
    public
    ifIsKnight(knightId)
  //ifOwnsItem(knightId)
    ifClanExists(clanId)
  {
    require(!clanExists(knightClan(knightId)) || notInClan(knightId),
      "ClanFacet: Leave your clan before joining a new one");
    if (proposal(knightId, clanId) == Proposal.INVITE) {
      //join clan immediately if invited
      CLAN.state().clan[clanId].totalMembers++;
      KNHT.state().knight[knightId].inClan = clanId;
      CLAN.state().proposal[knightId][clanId] = Proposal.NONE;
      emit KnightJoinedClan(clanId, knightId);
    } else {
      //create join proposal
      CLAN.state().proposal[knightId][clanId] = Proposal.JOIN;
      emit KnightAskedToJoin(clanId, knightId);
    }
  }

  //BOTH knights and leaders supposed call the leave function
  function leave(uint256 knightId)
    public
    ifIsKnight(knightId)
    ifIsInAnyClan(knightId)
  { 
    uint256 clanId = knightClan(knightId);
    if ((clanExists(clanId) && proposal(knightId, clanId) != Proposal.LEAVE)) {
      //create leave proposal if clan exist & such proposal doesn't
      CLAN.state().proposal[knightId][clanId] = Proposal.LEAVE;
      emit KnightAskedToLeave(clanId, knightId);
    } else if(ownsItem(clanLeader(clanId)) || clanExists(clanId) || isSBD()) {
      //leave abandoned clan or allow knight to leave if clan leader
      CLAN.state().clan[clanId].totalMembers--;
      KNHT.state().knight[knightId].inClan = 0;
      CLAN.state().proposal[knightId][clanId] = Proposal.NONE;
      emit KnightLeftClan(clanId, knightId);
    } else { 
      revert("ClanFacet: Either proposal already exist or you don't own a clan leader");
    }
  }

  //ONLY leaders supposed call the invite function
  function invite(uint256 knightId, uint256 clanId)
    public
    ifIsKnight(knightId)
  //ifOwnsItem(clanLeader(clanId))
    ifNotInClan(knightId)
  {
    if (proposal(knightId, clanId) == Proposal.JOIN && notInClan(knightId)) {
      //welcome the knight to join if it already offered it
      CLAN.state().clan[clanId].totalMembers++;
      KNHT.state().knight[knightId].inClan = clanId;
      CLAN.state().proposal[knightId][clanId] = Proposal.NONE;
      emit KnightJoinedClan(clanId, knightId);
    } else {
      //create invite proposal for the knight
      CLAN.state().proposal[knightId][clanId] = Proposal.INVITE;
      emit KnightInvitedToClan(clanId, knightId);
    }
  }

//Public getters

  function getClanLeader(uint clanId) public view returns(uint256) {
    return clanLeader(clanId);
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

  function getClanLevelThreshold(uint level) public view returns (uint) {
    return clanLevelThreshold(level);
  }

  function getClanMaxLevel() public view returns (uint) {
    return clanMaxLevel();
  }

  function getProposal(uint256 knightId, uint256 clanId) public view returns (Proposal) {
    return proposal(knightId, clanId);
  }
}
