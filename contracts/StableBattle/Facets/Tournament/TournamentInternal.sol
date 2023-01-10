// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.10;

import { ITournamentEvents } from "../Tournament/ITournament.sol";
import { ITournament } from "../Tournament/ITournament.sol";
import { TournamentStorage } from "../Tournament/TournamentStorage.sol";
import { TournamentGetters } from "../Tournament/TournamentGetters.sol";
import { TreasuryInternal } from "../Treasury/TreasuryInternal.sol";

contract TournamentInternal is 
  ITournamentEvents, 
  TournamentGetters,
  TreasuryInternal 
{
  function _updateCastleOwnership(uint clanId) internal {
    if (_castleHolderClan() != 0) { _claimRewards(); }
    TournamentStorage.state().castleHolderClan = clanId;
    emit CastleHolderChanged(clanId);
  }
}