// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.0;

import { IClan } from "../../shared/interfaces/IClan.sol";

contract ClanFacetDummy is IClan {
  
//Clan Facet
  
  function create(uint charId) external returns (uint clanId){}

  function dissolve(uint clanId) external{}

  function onStake(address benefactor, uint clanId, uint amount) external{}

  function onWithdraw(address benefactor, uint clanId, uint amount) external{}

  function join(uint charId, uint clanId) external{}

  function acceptJoin(uint256 charId, uint256 clanId) external{}

  function refuseJoin(uint256 charId, uint256 clanId) external{}

  function leave(uint256 charId, uint256 clanId) external{}

  function acceptLeave(uint256 charId, uint256 clanId) external{}

  function refuseLeave(uint256 charId, uint256 clanId) external{}
  
//Getters

  function getClanOwner(uint clanId) external view returns(uint256){}

  function getClanTotalMembers(uint clanId) external view returns(uint){}
  
  function getClanStake(uint clanId) external view returns(uint256){}

  function getClanLevel(uint clanId) external view returns(uint){}

  function getStakeOf(address benefactor, uint clanId) external view returns(uint256){}

  function getClanLevelThresholds(uint newLevel) external view returns (uint){}

  function getClanMaxLevel() external view returns (uint){}

  function getJoinProposal(uint256 knightId) external view returns (uint){}

  function getLeaveProposal(uint256 knightId) external view returns (uint){}
}
