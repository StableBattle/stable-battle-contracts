// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.0;

import { ITournament } from "../Tournament/ITournament.sol";
import { TournamentInternal } from "../Tournament/TournamentInternal.sol";
import { TournamentGetters } from "../Tournament/TournamentGetters.sol";
import { TournamentStorage } from "../Tournament/TournamentStorage.sol";

contract TournamentFacet is ITournament, TournamentGetters, TournamentInternal {
  using  TournamentStorage for TournamentStorage.State;

  function updateCastleOwnership(uint clanId) external {
    _updateCastleOwnership(clanId);
  }

//Public Getters
  function getCastleHolderClan() external view returns (uint256) {
    return _castleHolderClan();
  }
}