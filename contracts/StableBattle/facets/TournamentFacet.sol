// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.0;

import { ITournament } from "../../shared/interfaces/ITournament.sol";
import { TournamentStorage as TMNT } from "../storage/TournamentStorage.sol";
import { LibDiamond } from "../../shared/libraries/LibDiamond.sol";

contract TournamentFacet is ITournament {
  using TMNT for TMNT.Layout;

  function updateCastleOwnership(uint clanId) external onlyOwner {
    TMNT.layout().CastleHolder = clanId;
    emit CastleHolderChanged(clanId);
  }

  function castleHolder() external view returns(uint) {
    return TMNT.layout().CastleHolder;
  }

  modifier onlyOwner() {
    LibDiamond.enforceIsContractOwner();
    _;
  }

  //function updateLeaderboard() {}
}