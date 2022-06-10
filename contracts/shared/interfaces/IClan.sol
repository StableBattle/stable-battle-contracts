// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.10;

import { Clan } from "../../StableBattle/libraries/LibAppStorage.sol";

interface IClan {
  
  function Create(uint char_id) external returns (uint clan_id);

  function Dissolve(uint clan_id) external;

  function stakeOf(address benefactor, uint clan_id) external view returns(uint256);

  function onStake(address benefactor, uint clan_id, uint amount) external;

  function onWithdraw(address benefactor, uint clan_id, uint amount) external;

  function clanLevelOf(uint clan_id) external view returns(uint);

  function join(uint char_id, uint clan_id) external;

  function accept_join(uint256 char_id, uint256 clan_id) external;

  function refusejoin(uint256 char_id, uint256 clan_id) external;

  function leave(uint256 char_id, uint256 clan_id) external;

  function acceptleave(uint256 char_id, uint256 clan_id) external;

  function refuseleave(uint256 char_id, uint256 clan_id) external;

  event ClanCreated(uint clan_id, uint char_id);
  event ClanDissloved(uint clan_id);
  event StakedAdded(address benefactor, uint clan_id, uint amount);
  event StakedWithdrawn(address benefactor, uint clan_id, uint amount);
  event ClanLeveledUp(uint clan_id, uint new_level);
  event ClanLeveledDown(uint clan_id, uint new_level);
  event KnightAskedToJoin(uint clan_id, uint char_id);
  event KnightJoinedClan(uint clan_id, uint char_id);
  event JoinProposalRefused(uint clan_id, uint char_id);
  event KnightAskedToLeave(uint clan_id, uint char_id);
  event KnightLeavedClan(uint clan_id, uint char_id);
  event LeaveProposalRefused(uint clan_id, uint char_id);
}
