// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.0;

import { ClanStorage as Cs, Clan} from "../storage/ClanStorage.sol";
import { ERC1155Storage as ERC1155s} from "../storage/ERC1155Storage.sol";
import { KnightStorage as Ks} from "../storage/KnightStorage.sol";
import { IClan } from "../../shared/interfaces/IClan.sol";

contract ClanFacet is IClan {
  using Cs for Cs.Layout;
  using Ks for Ks.Layout;
  using ERC1155s for ERC1155s.Layout;

  function randomClanId() private view returns (uint clanId) {
    uint salt;
    do {
      salt++;
      clanId = uint(keccak256(abi.encodePacked(block.timestamp, tx.origin, salt)));
    } while (Cs.layout().clan[clanId].owner != 0);
  }
  
  function create(uint charId) external returns (uint clanId) {
    uint256 oldClanId = Ks.layout().knight[charId].inClan;
    require(charId > Ks.layout().knightOffset, "ClanFacet: Item is not a knight");
    require(ERC1155s.layout()._balances[charId][msg.sender] == 1,
            "ClanFacet: You don't own this knight");
    require(Cs.layout().clan[oldClanId].owner == 0,
            "ClanFacet: Leave a clan before creating your own");
    require(Ks.layout().knight[charId].ownsClan == 0, "ClanFacet: Only one clan per knight");
    clanId = randomClanId();
    Cs.layout().clan[clanId] = Clan(charId, 1, 0, 0);
    Ks.layout().knight[charId].inClan = clanId;
    Ks.layout().knight[charId].ownsClan = clanId;
    emit ClanCreated(clanId, charId);
  }

  function dissolve(uint clanId) external {
    uint charId = Cs.layout().clan[clanId].owner;
    require(ERC1155s.layout()._balances[charId][msg.sender] == 1,
            "ClanFacet: A knight owning this clan doesn't belong to you");
    Ks.layout().knight[charId].ownsClan = 0;
    Ks.layout().knight[charId].inClan = 0;
    Cs.layout().clan[clanId].owner = 0;
    emit ClanDissloved(clanId, charId);
  }

  function clanCheck(uint clanId) external view returns(Clan memory) {
    return Cs.layout().clan[clanId];
  }

  function clanOwner(uint clanId) external view returns(uint256) {
    return Cs.layout().clan[clanId].owner;
  }

  function clanTotalMembers(uint clanId) external view returns(uint) {
    return Cs.layout().clan[clanId].totalMembers;
  }
  
  function clanStake(uint clanId) external view returns(uint) {
    return Cs.layout().clan[clanId].stake;
  }

  function clanLevel(uint clanId) external view returns(uint) {
    return Cs.layout().clan[clanId].level;
  }

  function stakeOf(address benefactor, uint clanId) public view returns(uint256) {
    return (Cs.layout().stake[benefactor][clanId]);
  }

  function onStake(address benefactor, uint clanId, uint amount) external {
    require(Cs.layout().clan[clanId].owner != 0, "ClanFacet: This clan doesn't exist");

    Cs.layout().stake[benefactor][clanId] += amount;
    Cs.layout().clan[clanId].stake += amount;
    leveling(clanId);

    emit StakeAdded(benefactor, clanId, amount);
  }

  function onWithdraw(address benefactor, uint clanId, uint amount) external {
    require(stakeOf(benefactor, clanId) >= amount, "ClanFacet: Not enough SBT staked");
    
    Cs.layout().stake[benefactor][clanId] -= amount;
    Cs.layout().clan[clanId].stake -= amount;
    leveling(clanId);

    emit StakeWithdrawn(benefactor, clanId, amount);
  }

  //Calculate clan level based on stake
  function leveling(uint clanId) private {
    uint newLevel = 0;
    while (Cs.layout().clan[clanId].stake > Cs.layout().levelThresholds[newLevel] &&
           newLevel < Cs.layout().levelThresholds.length) {
      newLevel++;
    }
    if (Cs.layout().clan[clanId].level < newLevel) {
      Cs.layout().clan[clanId].level = newLevel;
      emit ClanLeveledUp (clanId, newLevel);
    } else if (Cs.layout().clan[clanId].level > newLevel) {
      Cs.layout().clan[clanId].level = newLevel;
      emit ClanLeveledDown (clanId, newLevel);
    }
  }

  function join(uint charId, uint clanId) external {
    uint256 oldClanId = Ks.layout().knight[charId].inClan;
    require(charId > Ks.layout().knightOffset,
      "ClanFacet: Item is not a knight");
    require(ERC1155s.layout()._balances[charId][msg.sender] == 1,
      "ClanFacet: You don't own this knight");
    require(Cs.layout().clan[oldClanId].owner == 0,
      "ClanFacet: Leave your old clan before joining a new one");
    
    Cs.layout().joinProposal[charId] = clanId;
    emit KnightAskedToJoin(clanId, charId);
  }

  function acceptJoin(uint256 charId, uint256 clanId) external {
    uint256 ownerId = Cs.layout().clan[clanId].owner;
    require(ERC1155s.layout()._balances[ownerId][msg.sender] == 1,
            "ClanFacet: A knight owning this clan doesn't belong to you");
    require(Cs.layout().joinProposal[charId] == clanId,
            "ClanFacet: This knight didn't offer to join your clan");

    Cs.layout().clan[clanId].totalMembers++;
    Ks.layout().knight[charId].inClan = clanId;
    Cs.layout().joinProposal[charId] = 0;

    emit KnightJoinedClan(clanId, charId);
  }

  function refuseJoin(uint256 charId, uint256 clanId) external {
    uint256 ownerId = Cs.layout().clan[clanId].owner;
    require(ERC1155s.layout()._balances[ownerId][msg.sender] == 1,
            "ClanFacet: A knight owning this clan doesn't belong to you");
    require(Cs.layout().joinProposal[charId] == clanId,
            "ClanFacet: This knight didn't offer to join your clan");
    
    Cs.layout().joinProposal[charId] = 0;

    emit JoinProposalRefused(clanId, charId);
  }

  function leave(uint256 charId, uint256 clanId) external {
    uint256 oldClanId = Ks.layout().knight[charId].inClan;
    require(ERC1155s.layout()._balances[charId][msg.sender] == 1,
      "ClanFacet: This knight doesn't belong to you");
    require(oldClanId == clanId, 
      "ClanFacet: Your knight doesn't belong to this clan");
    require(Cs.layout().clan[clanId].owner != charId,
      "ClanFacet: You can't leave your own clan");

    Cs.layout().leaveProposal[charId] = clanId;
    
    emit KnightAskedToLeave(clanId, charId);
  }

  function acceptLeave(uint256 charId, uint256 clanId) external {
    uint256 ownerId = Cs.layout().clan[clanId].owner;
    require(ERC1155s.layout()._balances[ownerId][msg.sender] == 1,
            "ClanFacet: A knight owning this clan doesn't belong to you");
    require(Cs.layout().leaveProposal[charId] == clanId,
            "ClanFacet: This knight didn't offer to leave your clan");

    Cs.layout().clan[clanId].totalMembers--;
    Ks.layout().knight[charId].inClan = 0;
    Cs.layout().leaveProposal[charId] = 0;

    emit KnightLeavedClan(clanId, charId);
  }

  function refuseLeave(uint256 charId, uint256 clanId) external {
    uint256 ownerId = Cs.layout().clan[clanId].owner;
    require(ERC1155s.layout()._balances[ownerId][msg.sender] == 1,
            "ClanFacet: A knight owning this clan doesn't belong to you");
    require(Cs.layout().leaveProposal[charId] == clanId,
            "ClanFacet: This knight didn't offer to leave your clan");
    
    Cs.layout().leaveProposal[charId] = 0;

    emit LeaveProposalRefused(clanId, charId);
  }
}
