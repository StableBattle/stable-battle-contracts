// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.0;

import { Coin } from "../../Meta/DataStructures.sol";

library KnightSetupLib {
  function knightPrice(Coin coin) internal pure returns(uint256) {
    return
      coin == Coin.USDT ? 1000*1e6 :
      coin == Coin.USDC ? 1000*1e6 :
      coin == Coin.EURS ? 1000*1e6 :
      0;
  }
}