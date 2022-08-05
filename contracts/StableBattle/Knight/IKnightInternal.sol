// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.0;

import { Coin, Pool } from "../Meta/MetaStorage.sol";

interface IKnightInternal {
  event KnightMinted (uint knightId, address wallet, Pool c, Coin p);
  event KnightBurned (uint knightId, address wallet, Pool c, Coin p);
}
