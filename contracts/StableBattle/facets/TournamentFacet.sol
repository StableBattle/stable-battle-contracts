// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.0;

import { TournamentStorage as TMNTs } from "../storage/TournamentStorage.sol";
import { LibDiamond } from "../../shared/libraries/LibDiamond.sol";

contract TournamentFacet {
  using TMNTs for TMNTs.Layout;

  function updateCastleOwnership(uint clanId) external onlyOwner {
    TMNTs.layout().CastleHolder = clanId;
    emit CastleHolderChanged(clanId);
  }

  function castleHolder() external view returns(uint) {
    return TMNTs.layout().CastleHolder;
  }

  modifier onlyOwner() {
    LibDiamond.enforceIsContractOwner();
    _;
  }

  event CastleHolderChanged(uint clanId);

  //function updateLeaderboard() {}
}