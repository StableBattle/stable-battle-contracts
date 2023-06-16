// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.10;

import { ITreasuryEvents, ITreasuryErrors } from "../Treasury/ITreasury.sol";
import { TreasuryStorage } from "../Treasury/TreasuryStorage.sol";
import { ExternalCalls } from "../../Meta/ExternalCalls.sol";
import { SiegeStorage } from "../Siege/SiegeStorage.sol";

contract TreasuryInternal is
  ITreasuryEvents,
  ITreasuryErrors,
  ExternalCalls
{
  function _claimRewards() internal {
    uint256 villageAmount = TreasuryStorage.layout().villageAmount;
    uint rewardPerBlock = TreasuryStorage.layout().rewardPerBlock;
    uint lastBlock = TreasuryStorage.layout().lastBlock;
    uint8 castleTax = TreasuryStorage.layout().castleTax;

    //Calculate reward
    uint256 paymentCycles = block.number - lastBlock;
    uint256 reward = rewardPerBlock * paymentCycles;
    //Assign rewards to village owners
    address[] memory owners = new address[](villageAmount + 1);
    uint256[] memory rewards = new uint256[](villageAmount + 1);
    for (uint v = 0; v < villageAmount; v++) {
      owners[v] = TreasuryStorage.layout().villageOwner[v];
      rewards[v] = reward * (100 - castleTax);
    }
    //Assign reward to castle holder clan leader
    owners[villageAmount] = SiegeStorage.layout().siegeWinnerAddress;
    rewards[villageAmount] = reward * castleTax;
    //Mint reward tokens
    TreasuryStorage.layout().lastBlock = block.number;
    BEER.treasuryMint(owners, rewards);
  }

  function _setTax(uint8 tax) internal {
    if (tax > 90) {
      revert TreasuryFacet_CantSetTaxAboveThreshold(90);
    }
    TreasuryStorage.layout().castleTax = tax;
    emit NewTaxSet(tax);
  }
}