// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.0;

import { ITournamentEvents } from "../Tournament/ITournamentEvents.sol";
import { ITournamentErrors } from "../Tournament/ITournamentErrors.sol";

interface ITournament is ITournamentEvents, ITournamentErrors {
  function updateCastleOwnership(uint clanId) external;

  function getCastleHolderClan() external view returns(uint);
}