// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.10;

import { ITournament } from "../Tournament/ITournament.sol";
import { TournamentInternal } from "../Tournament/TournamentInternal.sol";
import { TournamentGettersExternal } from "../Tournament/TournamentGetters.sol";
import { TournamentStorage } from "../Tournament/TournamentStorage.sol";

contract TournamentFacet is ITournament, TournamentInternal, TournamentGettersExternal {
  function updateCastleOwnership(uint clanId) external {
    _updateCastleOwnership(clanId);
  }
}