// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.10;

import { AppStorage, Clan } from "../libraries/LibAppStorage.sol";
import { IClan } from "../../shared/interfaces/IClan.sol";

contract ClanFacet is IClan {

  AppStorage internal s;
  
  function Create(uint char_id) external returns (uint clan_id) {
    uint256 old_clan_id = s.knight[char_id].inClan;
    require(char_id > s.knight_offset, "ClanFacet: Item is not a knight");
    require(s._balances[char_id][msg.sender] == 1,
            "ClanFacet: Only knights can create a clan");
    require(s.clan[old_clan_id].owner == 0,
            "ClanFacet: Leave a clan before creating your own");
    require(s.knight[char_id].ownsClan == 0, "ClanFacet: Only one clan per knight");
    s.clan[clan_id] = Clan(char_id, 1, 0, 0);
    s.knight[char_id].inClan = clan_id;
    s.knight[char_id].ownsClan = clan_id;
    clan_id++;
    emit ClanCreated(clan_id, char_id);
  }

  function Dissolve(uint clan_id) external {
    uint char_id = s.clan[clan_id].owner;
    require(s._balances[char_id][msg.sender] == 1,
            "ClanFacet: A knight owning this clan doesn't belong to you");
    s.knight[char_id].ownsClan = 0;
    s.clan[s.knight[char_id].inClan].owner = 0;
    emit ClanDissloved(clan_id);
  }

  function stakeOf(address benefactor, uint clan_id) public view returns(uint256) {
    return (s.stake[benefactor][clan_id]);
  }

  function onStake(address benefactor, uint clan_id, uint amount) external {
    require(s.clan[clan_id].owner != 0, "ClanFacet: This clan doesn't exist");

    s.stake[benefactor][clan_id] += amount;
    s.clan[clan_id].stake += amount;
    leveling(clan_id);

    emit StakedAdded (benefactor, clan_id, amount);
  }

  function onWithdraw(address benefactor, uint clan_id, uint amount) external {
    require(stakeOf(benefactor, clan_id) >= amount, "ClanFacet: Not enough SBT staked");
    
    s.stake[benefactor][clan_id] -= amount;
    s.clan[clan_id].stake -= amount;
    leveling(clan_id);

    emit StakedWithdrawn (benefactor, clan_id, amount);
  }

  //Calculate clan level based on stake
  function leveling(uint clan_id) private {
    uint new_level = 0;
    while (s.clan[clan_id].stake > s.levelThresholds[new_level] &&
           new_level < s.levelThresholds.length) {
      new_level++;
    }
    if (s.clan[clan_id].level < new_level) {
      s.clan[clan_id].level = new_level;
      emit ClanLeveledUp (clan_id, new_level);
    } else if (s.clan[clan_id].level > new_level) {
      s.clan[clan_id].level = new_level;
      emit ClanLeveledDown (clan_id, new_level);
    }
  }

  function clanLevelOf(uint clan_id) external view returns(uint) {
    return s.clan[clan_id].level;
  }

  function join(uint char_id, uint clan_id) external {
    uint256 old_clan_id = s.knight[char_id].inClan;
    require(char_id > s.knight_offset, "ClanFacet: Item is not a knight");
    require(s._balances[char_id][msg.sender] == 1,
            "ClanFacet: Only knights can join a clan");
    require(s.clan[old_clan_id].owner == 0,
            "ClanFacet: Leave your old clan before joining a new one");
    
    s.join_proposal[char_id] = clan_id;
    emit KnightAskedToJoin(clan_id, char_id);
  }

  function accept_join(uint256 char_id, uint256 clan_id) external {
    uint256 owner_id = s.clan[clan_id].owner;
    require(s._balances[owner_id][msg.sender] == 1,
            "ClanFacet: A knight owning this clan doesn't belong to you");
    require(s.join_proposal[char_id] == clan_id,
            "ClanFacet: This knight didn't offer to join your clan");

    s.clan[clan_id].total_members++;
    s.knight[char_id].inClan = clan_id;
    s.join_proposal[char_id] = 0;

    emit KnightJoinedClan(clan_id, char_id);
  }

  function refusejoin(uint256 char_id, uint256 clan_id) external {
    uint256 owner_id = s.clan[clan_id].owner;
    require(s._balances[owner_id][msg.sender] == 1,
            "ClanFacet: A knight owning this clan doesn't belong to you");
    require(s.join_proposal[char_id] == clan_id,
            "ClanFacet: This knight didn't offer to join your clan");
    
    s.join_proposal[char_id] = 0;

    emit JoinProposalRefused(clan_id, char_id);
  }

  function leave(uint256 char_id, uint256 clan_id) external {
    uint256 old_clan_id = s.knight[char_id].inClan;
    require(s._balances[char_id][msg.sender] == 1,
            "ClanFacet: This knight doesn't belong to you");
    require(old_clan_id == clan_id, "ClanFacet: Your knight doesn't belong to this clan");

    s.leave_proposal[char_id] = clan_id;
    
    emit KnightAskedToLeave(clan_id, char_id);
  }

  function acceptleave(uint256 char_id, uint256 clan_id) external {
    uint256 owner_id = s.clan[clan_id].owner;
    require(s._balances[owner_id][msg.sender] == 1,
            "ClanFacet: A knight owning this clan doesn't belong to you");
    require(s.leave_proposal[char_id] == clan_id,
            "ClanFacet: This knight didn't offer to leave your clan");

    s.clan[clan_id].total_members--;
    s.knight[char_id].inClan = 0;
    s.leave_proposal[char_id] = 0;

    emit KnightLeavedClan(clan_id, char_id);
  }

  function refuseleave(uint256 char_id, uint256 clan_id) external {
    uint256 owner_id = s.clan[clan_id].owner;
    require(s._balances[owner_id][msg.sender] == 1,
            "ClanFacet: A knight owning this clan doesn't belong to you");
    require(s.join_proposal[char_id] == clan_id,
            "ClanFacet: This knight didn't offer to leave your clan");
    
    s.leave_proposal[char_id] = 0;

    emit LeaveProposalRefused(clan_id, char_id);
  }
}
