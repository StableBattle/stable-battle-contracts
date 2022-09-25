// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.0;

import { SBTStorage } from "./SBTStorage.sol";
import { IClan } from "../StableBattle/Facets/Clan/IClan.sol";

abstract contract SBTGetters {
  using SBTStorage for SBTStorage.State;

  function Clan() internal view returns(IClan) {
    return IClan(SBTStorage.state().SBD);
  }
}