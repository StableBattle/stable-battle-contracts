// SPDX-License-Identifier: Unlicensed

pragma solidity ^0.8.0;

import { Coin, Pool } from "../Meta/DataStructures.sol";

import { IERC20 } from "solidstate-solidity/interfaces/IERC20.sol";
import { IBEER } from "../../BEER/IBEER.sol";
import { ISBV } from "../../SBV/ISBV.sol";

import { SetupAddressLib } from "../Init&Updates/SetupAddressLib.sol";
import { BEERAddressLib } from "../Init&Updates/BEERAddressLib.sol";
import { VillagesAddressLib } from "../Init&Updates/VillagesAddressLib.sol";

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
  function BEER() internal view virtual returns(IBEER) {
    return IBEER(BEERAddressLib.BEERAddress);
  }

  function SBV() internal view virtual returns(ISBV) {
    return ISBV(VillagesAddressLib.VillagesAddress);
  }

  function AAVE() internal view virtual returns(IAAVEBasic) {
    return IAAVEBasic(SetupAddressLib.getPoolAddress(Pool.AAVE));
  }

  function COIN(Coin coin) internal view virtual returns(IERC20) {
    return IERC20(SetupAddressLib.getACoinAddress(coin));
  }

  function ACOIN(Coin coin) internal view virtual returns(IERC20) {
    return IERC20(SetupAddressLib.getACoinAddress(coin));
  }

  function PoolAddress(Pool pool) internal view virtual returns(address) {
    return SetupAddressLib.getPoolAddress(pool);
  }
}