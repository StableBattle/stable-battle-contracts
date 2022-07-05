// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.0;

import { Clan } from "../../StableBattle/storage/ClanStorage.sol";
import { IClan } from "../../shared/interfaces/IClan.sol";

contract ClanFacetDummy is IClan {
  
  function create(uint charId) external returns (uint clanId){}

  function dissolve(uint clanId) external{}

  function clanCheck(uint clanId) external view returns(Clan memory){}

  function clanOwner(uint clanId) external view returns(uint256){}

  function clanTotalMembers(uint clanId) external view returns(uint){}
  
  function clanStake(uint clanId) external view returns(uint){}

  function clanLevel(uint clanId) external view returns(uint){}

  function stakeOf(address benefactor, uint clanId) external view returns(uint256){}

  function onStake(address benefactor, uint clanId, uint amount) external{}

  function onWithdraw(address benefactor, uint clanId, uint amount) external{}

  function join(uint charId, uint clanId) external{}

  function acceptJoin(uint256 charId, uint256 clanId) external{}

  function refuseJoin(uint256 charId, uint256 clanId) external{}

  function leave(uint256 charId, uint256 clanId) external{}

  function acceptLeave(uint256 charId, uint256 clanId) external{}

  function refuseLeave(uint256 charId, uint256 clanId) external{}
}
