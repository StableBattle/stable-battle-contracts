// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.0;

import { Clan } from "../../StableBattle/storage/ClanStorage.sol";

interface IClan {
  
  function create(uint charId) external returns (uint clanId);

  function dissolve(uint clanId) external;

  function onStake(address benefactor, uint clanId, uint amount) external;

  function onWithdraw(address benefactor, uint clanId, uint amount) external;

  function join(uint charId, uint clanId) external;

  function acceptJoin(uint256 charId, uint256 clanId) external;

  function refuseJoin(uint256 charId, uint256 clanId) external;

  function leave(uint256 charId, uint256 clanId) external;

  function acceptLeave(uint256 charId, uint256 clanId) external;

  function refuseLeave(uint256 charId, uint256 clanId) external;

  function clanCheck(uint clanId) external view returns(Clan memory);

  function clanOwner(uint clanId) external view returns(uint256);

  function clanTotalMembers(uint clanId) external view returns(uint);
  
  function clanStake(uint clanId) external view returns(uint);

  function clanLevel(uint clanId) external view returns(uint);

  function stakeOf(address benefactor, uint clanId) external view returns(uint256);

  function clanLevelThresholds(uint newLevel) external view returns (uint);

  function clanMaxLevel() external view returns (uint);

  function joinProposal(uint256 knightId) external view returns (uint);

  function leaveProposal(uint256 knightId) external view returns (uint);

  event ClanCreated(uint clanId, uint charId);
  event ClanDissloved(uint clanId, uint charId);
  event StakeAdded(address benefactor, uint clanId, uint amount);
  event StakeWithdrawn(address benefactor, uint clanId, uint amount);
  event ClanLeveledUp(uint clanId, uint newLevel);
  event ClanLeveledDown(uint clanId, uint newLevel);
  event KnightAskedToJoin(uint clanId, uint charId);
  event KnightJoinedClan(uint clanId, uint charId);
  event JoinProposalRefused(uint clanId, uint charId);
  event KnightAskedToLeave(uint clanId, uint charId);
  event KnightLeavedClan(uint clanId, uint charId);
  event LeaveProposalRefused(uint clanId, uint charId);
}
