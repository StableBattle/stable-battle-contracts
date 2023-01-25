// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.0;

interface ISiegeEvents {
  event SiegeNewWinner(uint256 clanId, uint256 knightId, address knightHolder, uint256 reward);
  event SiegeRewardClaimed(address to, uint256 knightId, uint256 amount);
}

interface ISiegeErrors {
  error ClaimAmountExceedsReward(uint256 amount, uint256 reward, uint256 knightId);
  error NoRewardToClaim(uint256 knightId);
}

interface ISiegeGetters {
  function getSiegeReward(uint256 knightId) external view returns(uint256);
  function getSiegeWinnerClanId() external view returns(uint256);
  function getSiegeWinnerKnightId() external view returns(uint256);
  function getSiegeWinnerAddress() external view returns(address);
  function getSiegeWinnerInfo() external view returns(uint256, uint256, address);
}

interface ISiege is ISiegeEvents, ISiegeErrors, ISiegeGetters {
  function setSiegeWinner(uint256 clanId) external;
  function claimSiegeReward(address to, uint256 knightId, uint256 amount) external;
}