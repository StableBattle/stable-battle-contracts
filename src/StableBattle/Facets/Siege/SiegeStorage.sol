// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.0;

import { Coin, Pool } from "../../Meta/DataStructures.sol";
import { KnightStorage } from "../Knight/KnightStorage.sol";
import { SetupAddressLib } from "../../Init&Updates/SetupAddressLib.sol";
import { IERC20 } from "solidstate-solidity/interfaces/IERC20.sol";

library SiegeStorage {
  struct Layout {
    //Id of a last clan that won the siege
    uint256 siegeWinnerClan;
    //Id of a last clan that won the siege
    uint256 siegeWinnerKnight;
    //Id of a last clan that won the siege
    address siegeWinnerAddress;
    //Knight id => reward amount
    mapping(address => uint256) reward;
    //Total anount of unclaimed rewards in a contract
    uint256 rewardTotal;
  }

  bytes32 internal constant STORAGE_SLOT = keccak256("Siege.storage");

  function layout() internal pure returns (Layout storage l) {
    bytes32 slot = STORAGE_SLOT;
    assembly {
      l.slot := slot
    }
  }
  
  function siegeYield() internal view returns(uint256) {
    uint256 stakeTotal = IERC20(SetupAddressLib.AUSDT).balanceOf(address(this));
    uint256 knightStake = 
      (
        KnightStorage.layout().knightsMinted[Pool.AAVE][Coin.USDT] - 
        KnightStorage.layout().knightsBurned[Pool.AAVE][Coin.USDT]
      ) * 1e9;
    return stakeTotal - knightStake - SiegeStorage.layout().rewardTotal;
  }
}