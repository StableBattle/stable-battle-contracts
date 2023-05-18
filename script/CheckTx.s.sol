// SPDX-License-Identifier: None
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import { IStableBattle } from "../src/StableBattle/Meta/IStableBattle.sol";
import { IERC20Metadata } from "openzeppelin-contracts/token/ERC20/extensions/IERC20Metadata.sol";

contract DeploySBGoerli is Script {
  IStableBattle StableBattle = IStableBattle(0x6551C3EC64aA6E97097467Bd0fD69B4D49c155Be);
  IERC20Metadata USDT = IERC20Metadata(0x07de306FF27a2B630B1141956844eB1552B956B5);
  string goerliForkURL = vm.envString("GOERLI_INFURA_URL");
  uint256 goerliFork;
  uint256 knightId = 115792089237316195423570985008687907853269984665640564039457584007913129639923;

  function run() external {
    goerliFork = vm.createSelectFork(goerliForkURL, 9016373);
    vm.prank(0x7727a13D98B7271c23fba99899920E7A22bd484D);
    StableBattle.burnKnight(knightId, 0);
  }
}