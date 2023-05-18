// SPDX-License-Identifier: Unlicensed

pragma solidity ^0.8.10;

import { Coin, Pool } from "../Meta/DataStructures.sol";

import { IERC20 } from "solidstate-solidity/interfaces/IERC20.sol";
import { IBEER } from "../../BEER/IBEER.sol";
import { ISBV } from "../../SBV/ISBV.sol";

import { SetupAddressLib } from "../Init&Updates/SetupAddressLib.sol";
import { BEERAddressLib } from "../Init&Updates/BEERAddressLib.sol";
import { SBVAddressLib } from "../Init&Updates/SBVAddressLib.sol";

interface IAAVEBasic {
  function supply(
    address asset,
    uint256 amount,
    address onBehalfOf,
    uint16 referralCode
  ) external;

  function withdraw(
    address asset,
    uint256 amount,
    address to
  ) external returns (uint256);
}

abstract contract ExternalCalls {
  IBEER constant BEER = IBEER(BEERAddressLib.BEERAddress);
  ISBV constant SBV = ISBV(SBVAddressLib.SBVAddress);
  IAAVEBasic constant AAVE = IAAVEBasic(SetupAddressLib.AAVE);

  function COIN(Coin coin) internal pure virtual returns(IERC20) {
    return IERC20(SetupAddressLib.CoinAddress(coin));
  }

  function ACOIN(Coin coin) internal pure virtual returns(IERC20) {
    return IERC20(SetupAddressLib.ACoinAddress(coin));
  }

  function PoolAddress(Pool pool) internal pure virtual returns(address) {
    return SetupAddressLib.PoolAddress(pool);
  }
}