// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.0;

import { ITournament } from "../../shared/interfaces/ITournament.sol";
import { TournamentStorage as TMNT, TournamentGetters } from "../storage/TournamentStorage.sol";
import { InternalCalls } from "../storage/MetaStorage.sol";

contract TournamentFacet is ITournament, TournamentGetters, InternalCalls {
  using TMNT for TMNT.State;

  function updateCastleOwnership(uint clanId) external {
    if (castleHolderClan() != 0) { TreasuryFacet().claimRewards(); }
    TMNT.state().castleHolderClan = clanId;
    emit CastleHolderChanged(clanId);
  }

//Public Getters

  function getCastleHolderClan() public view returns (uint256) {
    return castleHolderClan();
  }
}