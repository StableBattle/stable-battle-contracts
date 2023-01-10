// SPDX-License-Identifier: Unlicensed

pragma solidity ^0.8.0;

import { TournamentStorage } from "../Tournament/TournamentStorage.sol";
import { ITournamentGetters } from "../Tournament/ITournament.sol";

abstract contract TournamentGetters {
  function _castleHolderClan() internal view virtual returns (uint256) {
    return TournamentStorage.state().castleHolderClan;
  }
}

abstract contract TournamentGettersExternal is ITournamentGetters, TournamentGetters {
  function getCastleHolderClan() external view returns (uint256) {
    return _castleHolderClan();
  }
}