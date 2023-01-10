// SPDX-License-Identifier: Unlicensed

pragma solidity ^0.8.0;

import { Coin, Pool } from "./DataStructures.sol";

struct CompatibilityPair { Pool pool; Coin coin; }

library ConfigLib {
  bytes constant compatibility = abi.encode([
    CompatibilityPair(Pool.TEST, Coin.TEST),
    CompatibilityPair(Pool.AAVE, Coin.USDT),
    CompatibilityPair(Pool.AAVE, Coin.USDC)
  ]);
}