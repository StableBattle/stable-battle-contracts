// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.0;

import { ISiege } from "../Siege/ISiege.sol";

contract SiegeFacetDummy is ISiege {
  function getSiegeRewardTotal() external view returns(uint256) {}
  function getSiegeReward(address user) external view returns(uint256) {}
  function getSiegeWinnerClanId() external view returns(uint256) {}
  function getSiegeWinnerKnightId() external view returns(uint256) {}
  function getSiegeWinnerInfo() external view returns(uint256, uint256) {}
  function getSiegeYield() external view returns(uint256) {}
  function getYieldTotal() external view returns(uint256) {}

  function setSiegeWinner(uint256 clanId, uint256 knigthId, address user) external {}
  function claimSiegeReward(address user, uint256 amount) external {}
}
