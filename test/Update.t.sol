// SPDX-License-Identifier: None
pragma solidity ^0.8.0;

import {Test} from "forge-std/Test.sol";

import {Pool, Coin} from "../src/StableBattle/Meta/DataStructures.sol";
import {IStableBattle} from "../src/StableBattle/Meta/IStableBattle.sol";
import {IBEER} from "../src/BEER/IBEER.sol";
import {ISBV} from "../src/SBV/ISBV.sol";

import {SetupAddressLib} from "../src/StableBattle/Init&Updates/SetupAddressLib.sol";
import {DiamondAddressLib} from "../src/StableBattle/Init&Updates/DiamondAddressLib.sol";
import {TestSetups} from "./TestSetups.s.sol";

import {UpdateStableBattle} from "../script/UpdateStableBattle.s.sol";

contract UpdateTest is Test, TestSetups, UpdateStableBattle {
    uint256 goerliFork;

    function setUp() public {
        goerliFork = vm.createSelectFork(goerliForkURL);
    }

    function test_updateStableBattle() public {
        vm.startPrank(deployerAddress);
        updateStableBattle();
    }
}
