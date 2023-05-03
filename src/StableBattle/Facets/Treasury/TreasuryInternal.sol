// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.0;

import { ITreasuryEvents, ITreasuryErrors } from "../Treasury/ITreasury.sol";
import { TreasuryStorage } from "../Treasury/TreasuryStorage.sol";
import { TreasuryGetters } from "../Treasury/TreasuryGetters.sol";
import { KnightGetters } from "../Knight/KnightGetters.sol";
import { ClanGetters } from "../Clan/ClanGetters.sol";
import { SiegeGetters } from "../Siege/SiegeGetters.sol";
import { ExternalCalls } from "../../Meta/ExternalCalls.sol";

contract TreasuryInternal is
  ITreasuryEvents,
  ITreasuryErrors,
  TreasuryGetters,
  ClanGetters,
  KnightGetters,
  ExternalCalls,
  SiegeGetters
{
  function _claimRewards() internal {
    uint256 villageAmount = _villageAmount();

    //Calculate reward
    uint256 paymentCycles = block.number - _lastBlock();
    uint256 reward = _rewardPerBlock() * paymentCycles;
    //Assign rewards to village owners
    address[] memory owners = new address[](villageAmount + 1);
    uint256[] memory rewards = new uint256[](villageAmount + 1);
    for (uint v = 0; v < villageAmount; v++){
      owners[v] = _villageOwner(v);
      rewards[v] = reward * (100 - _castleTax());
    }
    //Assign reward to castle holder clan leader
    owners[villageAmount] = _siegeWinnerAddress();
    rewards[villageAmount] = reward * _castleTax();
    //Mint reward tokens
    TreasuryStorage.state().lastBlock = block.number;
    BEER().treasuryMint(owners, rewards);
  }

  function _setTax(uint8 tax) internal {
    if (tax > 90) {
      revert TreasuryFacet_CantSetTaxAboveThreshold(90);
    }
    TreasuryStorage.state().castleTax = tax;
    emit NewTaxSet(tax);
  }
}