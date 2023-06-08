// SPDX-License-Identifier: None
pragma solidity ^0.8.0;

import { Test } from "forge-std/Test.sol";

import { IBEER } from "../src/BEER/IBEER.sol";
import { IOFT } from "../src/BEER/OFT/IOFT.sol";
import { BEERImplementation } from "../src/BEER/BEERImplementation.sol";

import { TestSetups } from "../test/TestSetups.s.sol";
import { DeployStableBattle } from "../script/DeployStableBattle.s.sol";

contract BEEROFTTest is TestSetups {
  BEERImplementation BEER;
  IOFT OFT;
  uint256 goerliFork;
  
  function setUp() public {
    goerliFork = vm.createSelectFork(goerliForkURL, 8455800);
    vm.startBroadcast(deployerAddress);
    address BEERAddress = address(deployBEER(deployerAddress, bytes32(type(uint256).max - 2)));
    BEER = BEERImplementation(BEERAddress);
    BEER.mint(deployerAddress, 1000);
    OFT = IOFT(address(BEER));
  }

  function test_sendToRelayer() public {
    BEER.setTrustedRemote(10102, abi.encodePacked(deployerAddress, deployerAddress));
    BEER.sendFrom(
      deployerAddress,
      10102,
      abi.encodePacked(deployerAddress),
      100,
      payable(deployerAddress),
      address(0),
      ""
    );
  }
}
