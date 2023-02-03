// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.0;

interface ISiegeEvents {
  event SiegeNewWinner(uint256 clanId, uint256 knightId, address user, uint256 reward);
  event SiegeRewardClaimed(address user, uint256 amount);
}

interface ISiegeErrors {
  error ClaimAmountExceedsReward(uint256 amount, uint256 reward, address user);
  error NoRewardToClaim(address user);
}

interface ISiegeGetters {
  function getSiegeRewardTotal() external view returns(uint256);
  function getSiegeReward(address user) external view returns(uint256);
  function getSiegeWinnerClanId() external view returns(uint256);
  function getSiegeWinnerKnightId() external view returns(uint256);
  function getSiegeWinnerInfo() external view returns(uint256, uint256);
  function getSiegeYield() external view returns(uint256);
  function getYieldTotal() external view returns(uint256);
}

interface ISiege is ISiegeEvents, ISiegeErrors, ISiegeGetters {
  function setSiegeWinner(uint256 clanId, uint256 knigthId, address user) external;
  function claimSiegeReward(address user, uint256 amount) external;
}