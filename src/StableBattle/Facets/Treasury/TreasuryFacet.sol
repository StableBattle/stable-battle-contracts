// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.10;

import { ITreasury } from "../Treasury/ITreasury.sol";
import { TreasuryGettersExternal } from "../Treasury/TreasuryGetters.sol";
import { TreasuryInternal } from "../Treasury/TreasuryInternal.sol";
import { SiegeStorage } from "../Siege/SiegeStorage.sol";

contract TreasuryFacet is 
  ITreasury,
  TreasuryGettersExternal,
  TreasuryInternal
{
  function claimRewards() external {
    _claimRewards();
  }

  function setTax(uint8 tax) external {
    if(msg.sender != SiegeStorage.layout().siegeWinnerAddress) {
    //revert TreasuryModifiers_OnlyCallableByCastleHolder();
      revert("Treasury Facet: Only Callable By Castle Holder");
    }
    _setTax(tax);
  }
}