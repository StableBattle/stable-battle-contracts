// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.0;

import { ITournamentInternal } from "../Tournament/ITournamentInternal.sol";

interface ITournament is ITournamentInternal{

  function updateCastleOwnership(uint clanId) external;

  function getCastleHolderClan() external view returns(uint);
}