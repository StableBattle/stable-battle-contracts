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
  function setSiegeWinner(uint256 clanId) external ifCallerIsAdmin {
    uint256 knightStake = 
      (_knightsMinted(Pool.AAVE, Coin.USDT) - _knightsBurned(Pool.AAVE, Coin.USDT)) 
      * 1000
      * (10 ** ACOIN(Coin.USDT).decimals());
    uint256 reward = ACOIN(Coin.USDT).balanceOf(address(this)) - knightStake;
    uint256 knightId = _setSiegeWinnerKnight(clanId);
    SiegeStorage.state().siegeWinnerClan = clanId;
    SiegeStorage.state().reward[knightId] += reward;
    emit SiegeNewWinner(clanId, knightId, reward);
  }

  function claimSiegeReward(address to, uint256 knightId, uint256 amount) external ifOwnsItem(knightId) {
    uint256 reward = _siegeReward(knightId);
    if(reward == 0) { revert NoRewardToClaim(knightId); }
    if(amount > reward) {
      revert ClaimAmountExceedsReward(amount, reward, knightId);
    }
    SiegeStorage.state().reward[knightId] -= amount;
    AAVE().withdraw(address(COIN(Coin.USDT)), reward, to);
    emit SiegeRewardClaimed(to, knightId, amount);
  }
}