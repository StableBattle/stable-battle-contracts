// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.0;

import { ExternalCalls } from "../../Meta/ExternalCalls.sol";
import { Coin } from "../../Meta/DataStructures.sol";
import { AccessControlModifiers } from "../AccessControl/AccessControlModifiers.sol";
import { ItemsModifiers } from "../Items/ItemsModifiers.sol";
import { ERC1155BaseInternal } from "@solidstate/contracts/token/ERC1155/base/ERC1155BaseInternal.sol";

import { ISiege } from "../Siege/ISiege.sol";
import { SiegeStorage } from "../Siege/SiegeStorage.sol";
import { SiegeGettersExternal } from "../Siege/SiegeGetters.sol";

contract SiegeFacet is 
  ISiege,
  ERC1155BaseInternal,
  SiegeGettersExternal,
  ExternalCalls,
  AccessControlModifiers,
  ItemsModifiers
{
  function setSiegeWinner(uint256 clanId) external ifCallerIsAdmin {
    uint256 reward = ACOIN(Coin.USDT).balanceOf(address(this));
    uint256 knightId = _clanLeader(clanId);
    SiegeStorage.state().siegeWinnerClan = clanId;
    SiegeStorage.state().reward[knightId] += reward;
    emit SiegeNewWinner(knightId, clanId, reward);
  }

  function claimSiegeReward(uint256 knightId, uint256 amount) external ifOwnsItem(knightId) {
    uint256 reward = _siegeReward(knightId);
    address knightHolder = _accountsByToken(knightId)[0];
    if(reward == 0) { revert NoRewardToClaim(knightId); }
    if(amount > reward) {
      revert ClaimAmountExceedsReward(amount, reward, knightId);
    }
    SiegeStorage.state().reward[knightId] -= amount;
    AAVE().withdraw(address(COIN(Coin.USDT)), reward, knightHolder);
    emit SiegeRewardClaimed(knightId, amount);
  }
}