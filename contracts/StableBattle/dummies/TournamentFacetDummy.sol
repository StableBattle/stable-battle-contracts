// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.0;

import { ITournament } from "../../shared/interfaces/ITournament.sol";

contract TournamentFacetDummy is ITournament {

  function updateCastleOwnership(uint clanId) external {}

  function castleHolder() external view returns(uint) {}

}