// SPDX-License-Identifier: Unlicensed

pragma solidity ^0.8.10;

import { Coin, Pool } from "../Meta/DataStructures.sol";

import { IERC20 } from "@solidstate/contracts/token/ERC20/IERC20.sol";
import { IPool } from "@aave/core-v3/contracts/interfaces/IPool.sol";
import { ISBT } from "../../SBT/ISBT.sol";
import { ISBV } from "../../SBV/ISBV.sol";

import { MetaStorage } from "./MetaStorage.sol";

abstract contract ExternalCalls {
  function SBT() internal view virtual returns (ISBT) {
    return ISBT(MetaStorage.state().SBT);
  }

  function SBV() internal view virtual returns (ISBV) {
    return ISBV(MetaStorage.state().SBV);
  }

  function AAVE() internal view virtual returns (IPool) {
    return IPool(MetaStorage.state().pool[Pool.AAVE]);
  }

  function COIN(Coin coin) internal view virtual returns (IERC20) {
    return IERC20(MetaStorage.state().coin[coin]);
  }

  function ACOIN(Coin coin) internal view virtual returns (IERC20) {
    return IERC20(MetaStorage.state().acoin[coin]);
  }

  function PoolAddress(Pool pool) internal view virtual returns (address) {
    return MetaStorage.state().pool[pool];
  }

  function PoolAndCoinCompatibility(Pool p, Coin c) internal view returns (bool) {
    return MetaStorage.state().compatible[p][c];
  }
}