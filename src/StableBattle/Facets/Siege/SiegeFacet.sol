// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.0;

import { ExternalCalls } from "../../Meta/ExternalCalls.sol";
import { Pool, Coin } from "../../Meta/DataStructures.sol";
import { AccessControlModifiers } from "../AccessControl/AccessControlModifiers.sol";
import { ItemsModifiers } from "../Items/ItemsModifiers.sol";
import { KnightGetters } from "../Knight/KnightGetters.sol";

import { ISiege } from "../Siege/ISiege.sol";
import { SiegeStorage } from "../Siege/SiegeStorage.sol";
import { SiegeGettersExternal } from "../Siege/SiegeGetters.sol";
import { SiegeInternal } from "../Siege/SiegeInternal.sol";

contract SiegeFacet is 
  ISiege,
  SiegeInternal,
  SiegeGettersExternal,
  AccessControlModifiers,
  ItemsModifiers,
  KnightGetters
{
  function setSiegeWinner(uint256 clanId, uint256 knightId, address user)
    external 
  //ifCallerIsAdmin
  {
    uint256 reward = _siegeYield();
    if(_knightClan(knightId) != clanId) {
      revert();
    }
    if(_balanceOf(user, knightId) < 1) {
      revert();
    }
    SiegeStorage.layout().siegeWinnerClan = clanId;
    SiegeStorage.layout().siegeWinnerKnight = knightId;
    SiegeStorage.layout().siegeWinnerAddress = user;
    SiegeStorage.layout().reward[user] += reward;
    SiegeStorage.layout().rewardTotal += reward;
    emit SiegeNewWinner(clanId, knightId, user, reward);
  }

  function claimSiegeReward(address user, uint256 amount) external {
    uint256 reward = _siegeReward(user);
    if(reward == 0) { revert NoRewardToClaim(user); }
    if(amount > reward) {
      revert ClaimAmountExceedsReward(amount, reward, user);
    }
    SiegeStorage.layout().reward[user] -= amount;
    SiegeStorage.layout().rewardTotal -= amount;
    AAVE.withdraw(address(COIN(Coin.USDT)), amount, user);
    emit SiegeRewardClaimed(user, amount);
  }
}