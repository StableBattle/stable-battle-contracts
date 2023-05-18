// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.0;

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

  function _siegeRewardTotal() internal view returns(uint256) {
    return layout().rewardTotal;
  }

  function _siegeReward(address user) internal view returns(uint256) {
    return layout().reward[user];
  }

  function _siegeWinnerClan() internal view returns(uint256) {
    return layout().siegeWinnerClan;
  }

  function _siegeWinnerKnight() internal view returns(uint256) {
    return layout().siegeWinnerKnight;
  }

  function _siegeWinnerAddress() internal view returns(address) {
    return layout().siegeWinnerAddress;
  }
}