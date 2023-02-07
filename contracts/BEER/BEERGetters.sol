// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.0;

import { BEERStorage } from "./BEERStorage.sol";
import { IClan } from "../StableBattle/Facets/Clan/IClan.sol";

abstract contract BEERGetters {
  function Clan() internal view returns(IClan) {
    return IClan(BEERStorage.state().SBD);
  }
}