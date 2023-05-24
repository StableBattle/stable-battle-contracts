// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.0;

import { IClan } from "../StableBattle/Facets/Clan/IClan.sol";
import { DiamondAddressLib } from "../StableBattle/Init&Updates/DiamondAddressLib.sol";

abstract contract BEERGetters {
  function Clan() internal pure returns(IClan) {
    return IClan(DiamondAddressLib.DiamondAddress);
  }

  function SBD() internal pure returns(address) {
    return DiamondAddressLib.DiamondAddress;
  }
}