// SPDX-License-Identifier: Unlicensed

pragma solidity ^0.8.0;

import {Coin, Pool} from "../Meta/DataStructures.sol";
//import { GoerliAddressLib } from "./GoerliAddressLib.sol";
//import {BlastAddressLib} from "./BlastAddressLib.sol";
import {ModeAddressLib} from "./ModeAddressLib.sol";

library SetupAddressLib {
    address constant AAVE = ModeAddressLib.AAVE;

    address constant USDT = ModeAddressLib.USDT;
    address constant USDC = ModeAddressLib.USDC;
    address constant EURS = ModeAddressLib.EURS;

    address constant AUSDT = ModeAddressLib.AUSDT;
    address constant AUSDC = ModeAddressLib.AUSDC;
    address constant AEURS = ModeAddressLib.AEURS;

    function CoinAddress(Coin c) internal pure returns (address) {
        return c == Coin.USDT ? USDT : c == Coin.USDC ? USDC : c == Coin.EURS ? EURS : address(0);
    }

    function ACoinAddress(Coin c) internal pure returns (address) {
        return c == Coin.USDT ? AUSDT : c == Coin.USDC ? AUSDC : c == Coin.EURS ? AEURS : address(0);
    }

    function PoolAddress(Pool p) internal pure returns (address) {
        return p == Pool.AAVE ? AAVE : address(0);
    }

    function isCompatible(Pool p, Coin c) internal pure returns (bool) {
        return p == Pool.AAVE ? c == Coin.USDT ? true : false : false;
    }
}
