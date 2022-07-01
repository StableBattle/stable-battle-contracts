// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.0;

import { ClanStorage as CLAN, Clan } from "../storage/ClanStorage.sol";
import { ItemsStorage as ITEM } from "../storage/ItemsStorage.sol";
import { KnightStorage as KNHT } from "../storage/KnightStorage.sol";
import { IClan } from "../../shared/interfaces/IClan.sol";

contract ClanFacet is IClan {
  using CLAN for CLAN.Layout;
  using KNHT for KNHT.Layout;
  using ITEM for ITEM.Layout;

  function randomClanId() private view returns (uint clanId) {
    uint salt;
    do {
      salt++;
      clanId = uint(keccak256(abi.encodePacked(block.timestamp, tx.origin, salt)));
    } while (CLAN.layout().clan[clanId].owner != 0);
  }
  
  function create(uint charId) external returns (uint clanId) {
    uint256 oldClanId = KNHT.layout().knight[charId].inClan;
    require(charId > KNHT.layout().knightOffset, "ClanFacet: Item is not a knight");
    require(ITEM.layout()._balances[charId][msg.sender] == 1,
            "ClanFacet: You don't own this knight");
    require(CLAN.layout().clan[oldClanId].owner == 0,
            "ClanFacet: Leave a clan before creating your own");
    require(KNHT.layout().knight[charId].ownsClan == 0, "ClanFacet: Only one clan per knight");
    clanId = randomClanId();
    CLAN.layout().clan[clanId] = Clan(charId, 1, 0, 0);
    KNHT.layout().knight[charId].inClan = clanId;
    KNHT.layout().knight[charId].ownsClan = clanId;
    emit ClanCreated(clanId, charId);
  }

  function dissolve(uint clanId) external {
    uint charId = CLAN.layout().clan[clanId].owner;
    require(ITEM.layout()._balances[charId][msg.sender] == 1,
            "ClanFacet: A knight owning this clan doesn't belong to you");
    KNHT.layout().knight[charId].ownsClan = 0;
    KNHT.layout().knight[charId].inClan = 0;
    CLAN.layout().clan[clanId].owner = 0;
    emit ClanDissloved(clanId, charId);
  }

  function clanCheck(uint clanId) external view returns(Clan memory) {
    return CLAN.layout().clan[clanId];
  }

  function clanOwner(uint clanId) external view returns(uint256) {
    return CLAN.layout().clan[clanId].owner;
  }

  function clanTotalMembers(uint clanId) external view returns(uint) {
    return CLAN.layout().clan[clanId].totalMembers;
  }
  
  function clanStake(uint clanId) external view returns(uint) {
    return CLAN.layout().clan[clanId].stake;
  }

  function clanLevel(uint clanId) external view returns(uint) {
    return CLAN.layout().clan[clanId].level;
  }

  function stakeOf(address benefactor, uint clanId) public view returns(uint256) {
    return (CLAN.layout().stake[benefactor][clanId]);
  }

  function onStake(address benefactor, uint clanId, uint amount) external {
    require(CLAN.layout().clan[clanId].owner != 0, "ClanFacet: This clan doesn't exist");

    CLAN.layout().stake[benefactor][clanId] += amount;
    CLAN.layout().clan[clanId].stake += amount;
    leveling(clanId);

    emit StakeAdded(benefactor, clanId, amount);
  }

  function onWithdraw(address benefactor, uint clanId, uint amount) external {
    require(stakeOf(benefactor, clanId) >= amount, "ClanFacet: Not enough SBT staked");
    
    CLAN.layout().stake[benefactor][clanId] -= amount;
    CLAN.layout().clan[clanId].stake -= amount;
    leveling(clanId);

    emit StakeWithdrawn(benefactor, clanId, amount);
  }

  //Calculate clan level based on stake
  function leveling(uint clanId) private {
    uint newLevel = 0;
    while (CLAN.layout().clan[clanId].stake > CLAN.layout().levelThresholds[newLevel] &&
           newLevel < CLAN.layout().levelThresholds.length) {
      newLevel++;
    }
    if (CLAN.layout().clan[clanId].level < newLevel) {
      CLAN.layout().clan[clanId].level = newLevel;
      emit ClanLeveledUp (clanId, newLevel);
    } else if (CLAN.layout().clan[clanId].level > newLevel) {
      CLAN.layout().clan[clanId].level = newLevel;
      emit ClanLeveledDown (clanId, newLevel);
    }
  }

  function join(uint charId, uint clanId) external {
    uint256 oldClanId = KNHT.layout().knight[charId].inClan;
    require(charId > KNHT.layout().knightOffset,
      "ClanFacet: Item is not a knight");
    require(ITEM.layout()._balances[charId][msg.sender] == 1,
      "ClanFacet: You don't own this knight");
    require(CLAN.layout().clan[oldClanId].owner == 0,
      "ClanFacet: Leave your old clan before joining a new one");
    
    CLAN.layout().joinProposal[charId] = clanId;
    emit KnightAskedToJoin(clanId, charId);
  }

  function acceptJoin(uint256 charId, uint256 clanId) external {
    uint256 ownerId = CLAN.layout().clan[clanId].owner;
    require(ITEM.layout()._balances[ownerId][msg.sender] == 1,
            "ClanFacet: A knight owning this clan doesn't belong to you");
    require(CLAN.layout().joinProposal[charId] == clanId,
            "ClanFacet: This knight didn't offer to join your clan");

    CLAN.layout().clan[clanId].totalMembers++;
    KNHT.layout().knight[charId].inClan = clanId;
    CLAN.layout().joinProposal[charId] = 0;

    emit KnightJoinedClan(clanId, charId);
  }

  function refuseJoin(uint256 charId, uint256 clanId) external {
    uint256 ownerId = CLAN.layout().clan[clanId].owner;
    require(ITEM.layout()._balances[ownerId][msg.sender] == 1,
            "ClanFacet: A knight owning this clan doesn't belong to you");
    require(CLAN.layout().joinProposal[charId] == clanId,
            "ClanFacet: This knight didn't offer to join your clan");
    
    CLAN.layout().joinProposal[charId] = 0;

    emit JoinProposalRefused(clanId, charId);
  }

  function leave(uint256 charId, uint256 clanId) external {
    uint256 oldClanId = KNHT.layout().knight[charId].inClan;
    require(ITEM.layout()._balances[charId][msg.sender] == 1,
      "ClanFacet: This knight doesn't belong to you");
    require(oldClanId == clanId, 
      "ClanFacet: Your knight doesn't belong to this clan");
    require(CLAN.layout().clan[clanId].owner != charId,
      "ClanFacet: You can't leave your own clan");

    CLAN.layout().leaveProposal[charId] = clanId;
    
    emit KnightAskedToLeave(clanId, charId);
  }

  function acceptLeave(uint256 charId, uint256 clanId) external {
    uint256 ownerId = CLAN.layout().clan[clanId].owner;
    require(ITEM.layout()._balances[ownerId][msg.sender] == 1,
            "ClanFacet: A knight owning this clan doesn't belong to you");
    require(CLAN.layout().leaveProposal[charId] == clanId,
            "ClanFacet: This knight didn't offer to leave your clan");

    CLAN.layout().clan[clanId].totalMembers--;
    KNHT.layout().knight[charId].inClan = 0;
    CLAN.layout().leaveProposal[charId] = 0;

    emit KnightLeavedClan(clanId, charId);
  }

  function refuseLeave(uint256 charId, uint256 clanId) external {
    uint256 ownerId = CLAN.layout().clan[clanId].owner;
    require(ITEM.layout()._balances[ownerId][msg.sender] == 1,
            "ClanFacet: A knight owning this clan doesn't belong to you");
    require(CLAN.layout().leaveProposal[charId] == clanId,
            "ClanFacet: This knight didn't offer to leave your clan");
    
    CLAN.layout().leaveProposal[charId] = 0;

    emit LeaveProposalRefused(clanId, charId);
  }
}
