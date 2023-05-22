// SPDX-License-Identifier: None
pragma solidity ^0.8.0;

import { Test } from "forge-std/Test.sol";
import { Pool, Coin } from "../src/StableBattle/Meta/DataStructures.sol";
import { IStableBattle } from "../src/StableBattle/Meta/IStableBattle.sol";
import { IBEER } from "../src/BEER/IBEER.sol";
import { ISBV } from "../src/SBV/ISBV.sol";
import { IERC20 } from "openzeppelin-contracts/token/ERC20/IERC20.sol";
import { DeployStableBattle } from "../script/DeployStableBattle.s.sol";
import { SetupAddressLib } from "../src/StableBattle/Init&Updates/SetupAddressLib.sol";

abstract contract TestSetups is Test, DeployStableBattle {
  IERC20 constant USDT = IERC20(SetupAddressLib.USDT);
  address immutable deployerAddress = vm.envAddress("PUBLIC_KEY");
  address immutable richUSDTAddress = vm.envAddress("PUBLIC_KEY");
  string goerliForkURL = vm.envString("GOERLI_INFURA_URL");

  function setupStableBattle(address deployer)
    internal
    returns(IStableBattle, IBEER, ISBV)
  {
    vm.startBroadcast(deployer);
    (IStableBattle StableBattle, IBEER BEER, ISBV SBV) = deployStableBattle(deployer, 0);
    vm.stopBroadcast();
    return (StableBattle, BEER, SBV);
  }

  function mintKnights_AAVE_USDT(IStableBattle StableBattle, uint256 amount)
    internal
    returns(address[] memory, uint256[] memory)
  {
    address[] memory users = new address[](amount);
    uint256[] memory knights = new uint256[](amount);
    uint256 knightPrice = StableBattle.getKnightPrice(Coin.USDT);
    for(uint i = 0; i < amount; ++i) {
      users[i] = vm.addr(i + 1);
      vm.deal(users[i], 1 ether);
      vm.prank(richUSDTAddress);
      USDT.transfer(users[i], knightPrice);
      vm.prank(users[i]);
      USDT.approve(address(StableBattle), knightPrice);
      vm.prank(users[i]);
      knights[i] = StableBattle.mintKnight(Pool.AAVE, Coin.USDT);
    }
    return (users, knights);
  }
}