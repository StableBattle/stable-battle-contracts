// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.0;

import { IClan } from "../StableBattle/Facets/Clan/IClan.sol";
import { StableBattleAddressLib } from "../StableBattle/Init&Updates/StableBattleAddressLib.sol";

abstract contract BEERGetters {
  function Clan() internal pure returns(IClan) {
    return IClan(StableBattleAddressLib.StableBattleAddress);
  }

  function SBD() internal pure returns(address) {
    return StableBattleAddressLib.StableBattleAddress;
  }
}