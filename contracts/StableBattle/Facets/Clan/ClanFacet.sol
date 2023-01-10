// SPDX-License-Identifier: Unlicensed

pragma solidity ^0.8.0;

import { Clan, Proposal } from "../../Meta/DataStructures.sol";

import { IClan } from "../Clan/IClan.sol";
import { ClanStorage } from "../Clan/ClanStorage.sol";
import { ClanInternal } from "../Clan/ClanInternal.sol";
import { ItemsModifiers } from "../Items/ItemsModifiers.sol";
import { MetaModifiers } from "../../Meta/MetaModifiers.sol";
import { ClanGettersExternal } from "../Clan/ClanGetters.sol";

contract ClanFacet is
  IClan,
  ItemsModifiers,
  ClanInternal,
  MetaModifiers,
  ClanGettersExternal
{

//Creation, Abandonment and Leader Change
  function create(uint256 knightId)
    external
  //ifOwnsItem(knightId)
    returns(uint)
  { return _create(knightId); }

  function abandon(uint256 clanId) 
    external 
  //ifOwnsItem(clanLeader(clanId))
  { _abandon(clanId); }

  function changeLeader(uint256 clanId, uint256 knightId)
    external
  //ifOwnsItem(clanLeader(clanId))
  { _changeLeader(clanId, knightId); }

// Clan stakes and leveling
  function onStake(address benefactor, uint256 clanId, uint256 amount)
    external
  //onlySBT
  { _onStake(benefactor, clanId, amount); }

  function onWithdraw(address benefactor, uint256 clanId, uint256 amount)
    external
  //onlySBT
  { _onWithdraw(benefactor, clanId, amount); }

//Join, Leave and Invite Proposals
  //ONLY knight supposed call the join function
  function join(uint256 knightId, uint256 clanId)
    external
  //ifOwnsItem(knightId)
  { _join(knightId, clanId); }

  //BOTH knights and leaders supposed call the leave function
  function leave(uint256 knightId)
    external
  { _leave(knightId); }

  //ONLY leaders supposed call the invite function
  function invite(uint256 knightId, uint256 clanId)
    external
  //ifOwnsItem(clanLeader(clanId))
  { _invite(knightId, clanId); }
}
