// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.10;

import { ITournamentInternal } from "../Tournament/ITournamentInternal.sol";
import { ITournament } from "../Tournament/ITournament.sol";
import { TournamentStorage } from "../Tournament/TournamentStorage.sol";
import { TournamentGetters } from "../Tournament/TournamentGetters.sol";
import { TreasuryInternal } from "../Treasury/TreasuryInternal.sol";

contract TournamentInternal is 
  ITournamentInternal, 
  TournamentGetters,
  TreasuryInternal 
{
  using  TournamentStorage for TournamentStorage.State;

  function _updateCastleOwnership(uint clanId) internal {
    if (_castleHolderClan() != 0) { _claimRewards(); }
    TournamentStorage.state().castleHolderClan = clanId;
    emit CastleHolderChanged(clanId);
  }
}