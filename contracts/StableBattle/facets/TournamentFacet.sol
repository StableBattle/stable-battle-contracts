// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.0;

import { ITournament } from "../../shared/interfaces/ITournament.sol";
import { TournamentStorage as TMNT } from "../storage/TournamentStorage.sol";
import { MetaStorage as META } from "../storage/MetaStorage.sol";
import { ITreasury } from "../../shared/interfaces/ITreasury.sol";

contract TournamentFacet is ITournament {
  using TMNT for TMNT.State;

  function updateCastleOwnership(uint clanId) external {
    if (castleHolder() != 0) {
      ITreasury(META.SBDAddress()).claimRewards();
    }
    TMNT.state().castleHolder = clanId;
    emit CastleHolderChanged(clanId);
  }

  function castleHolder() public view returns(uint) {
    return TMNT.castleHolder();
  }

  //function updateLeaderboard() {}
}