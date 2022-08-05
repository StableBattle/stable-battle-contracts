// SPDX-License-Identifier: Unlicensed

pragma solidity ^0.8.0;

import { TournamentStorage } from "../Tournament/TournamentStorage.sol";

abstract contract TournamentGetters {
  function _castleHolderClan() internal view virtual returns (uint256) {
    return TournamentStorage.state().castleHolderClan;
  }
}