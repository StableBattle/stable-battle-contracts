// SPDX-License-Identifier: None
pragma solidity ^0.8.0;

import { Test } from "forge-std/Test.sol";

import { IStableBattle } from "../src/StableBattle/Meta/IStableBattle.sol";
import { IBEER } from "../src/BEER/IBEER.sol";
import { ISBV } from "../src/SBV/ISBV.sol";

import { DeployStableBattle } from "../script/DeployStableBattle.s.sol";

abstract contract DepolyTest is Test, DeployStableBattle {
  IStableBattle StableBattle;
  IBEER BEER;
  ISBV SBV;
  uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
  address deployerAddress = vm.envAddress("PUBLIC_KEY");
  string goerliForkURL = vm.envString("GOERLI_INFURA_URL");

  function setUp() public {}

  function testDeploy() public {
    vm.startBroadcast(deployerPrivateKey);
    (StableBattle, BEER, SBV) = deployStableBattle(deployerAddress, 0);
    vm.stopBroadcast();
    vm.createSelectFork(goerliForkURL);
  }
}