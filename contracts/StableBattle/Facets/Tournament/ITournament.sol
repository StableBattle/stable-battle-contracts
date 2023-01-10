// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.0;

interface ITournamentEvents {
  event CastleHolderChanged(uint clanId);
}

interface ITournamentErrors {}

interface ITournamentGetters {
  function getCastleHolderClan() external view returns(uint);
}

interface ITournament is ITournamentEvents, ITournamentErrors, ITournamentGetters {
  function updateCastleOwnership(uint clanId) external;
}