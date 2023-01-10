// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.0;

import { IDemoFight } from "./IDemoFight.sol";
import { DemoFightInternal } from "../DemoFight/DemoFightInternal.sol";
import { AccessControlModifiers } from "../AccessControl/AccessControlModifiers.sol";
import { DemoFightGettersExternal } from "../DemoFight/DemoFightGetters.sol";

contract DemoFightFacet is 
  IDemoFight,
  DemoFightInternal,
  AccessControlModifiers,
  DemoFightGettersExternal
{
  function battleWonBy(address user, uint256 reward) public ifCallerIsAdmin {
    _battleWonBy(user, reward);
  }

  function claimReward(address user) public {
    _claimReward(user);
  }
}
