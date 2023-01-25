// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.0;

import { ISiege } from "../Siege/ISiege.sol";

contract SiegeFacetDummy is ISiege {
  function getSiegeReward(uint256 knightId) external view returns(uint256) {}
  function getSiegeWinnerClanId() external view returns(uint256) {}
  function getSiegeWinnerKnightId() external view returns(uint256) {}
  function getSiegeWinnerAddress() external view returns(address) {}
  function getSiegeWinnerInfo() external view returns(uint256, uint256, address) {}

  function setSiegeWinner(uint256 clanId) external {}
  function claimSiegeReward(uint256 knightId, uint256 amount) external {}
}
