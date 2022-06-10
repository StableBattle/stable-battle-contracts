// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.10;

import { AppStorage } from "../libraries/LibAppStorage.sol";

contract TournamentFacet {

  AppStorage internal s;

  function updateCastleOwnership(uint clan_id) external {
    s.CastleHolder = clan_id;
  }

  //function updateLeaderboard() {}
}