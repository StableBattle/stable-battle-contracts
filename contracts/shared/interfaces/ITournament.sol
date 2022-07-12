// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.0;

interface ITournament {

  function updateCastleOwnership(uint clanId) external;

  function getCastleHolderClan() external view returns(uint);

  event CastleHolderChanged(uint clanId);
}