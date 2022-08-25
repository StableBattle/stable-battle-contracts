// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.0;

import { ITournament } from "./ITournament.sol";

contract TournamentFacetDummy is ITournament {

  function updateCastleOwnership(uint clanId) external {}

  function getCastleHolderClan() external view returns(uint){}

}