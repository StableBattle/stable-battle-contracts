// SPDX-License-Identifier: None
pragma solidity ^0.8.0;

import { Test } from "forge-std/Test.sol";

import { Pool, Coin } from "../src/StableBattle/Meta/DataStructures.sol";
import { IStableBattle } from "../src/StableBattle/Meta/IStableBattle.sol";
import { IBEER } from "../src/BEER/IBEER.sol";
import { ISBV } from "../src/SBV/ISBV.sol";

import { SetupAddressLib } from "../src/StableBattle/Init&Updates/SetupAddressLib.sol";
import { TestSetups } from "./TestSetups.s.sol";

contract KnightFacetTest is Test, TestSetups {
  IStableBattle StableBattle;
  IBEER BEER;
  ISBV SBV;
  uint256 goerliFork;
  address user = vm.addr(1);
  
  function setUp() public {
    goerliFork = vm.createSelectFork(goerliForkURL);
    vm.startBroadcast(deployerAddress);
    (StableBattle, BEER, SBV) = deployStableBattle(deployerAddress, 0);
    USDT.transfer(user, StableBattle.getKnightPrice(Coin.USDT));
    vm.stopBroadcast();
    vm.startPrank(user);
    USDT.approve(address(StableBattle), StableBattle.getKnightPrice(Coin.USDT));
  }

  function test_mintKnight() public returns(uint256 knightId) {
    knightId = StableBattle.mintKnight(Pool.AAVE, Coin.USDT);
    assertEq(StableBattle.balanceOf(user, knightId), 1);
    assertEq(StableBattle.getKnightsMintedOfCoin(Coin.USDT), 1);
    assertEq(StableBattle.getKnightsMintedOfPool(Pool.AAVE), 1);
    assertEq(StableBattle.getKnightsMintedTotal(), 1);
    assertEq(StableBattle.getTotalKnightSupply(), 1);
  }

  function test_mintKnight_revert_poolCoinCompatibility() public {
    vm.expectRevert("MetaModifiers: Incompatible pool coin");
    StableBattle.mintKnight(Pool.NONE, Coin.NONE);
  }

  function test_mintKnight_revert_insufficientAllowance() public {
    USDT.approve(address(StableBattle), StableBattle.getKnightPrice(Coin.USDT) - 1);
    vm.expectRevert("KnightFacet: Insufficient allowance");
    StableBattle.mintKnight(Pool.AAVE, Coin.USDT);
  }

  function test_burnKnight() public {
    uint256 knightId = StableBattle.mintKnight(Pool.AAVE, Coin.USDT);
    StableBattle.burnKnight(knightId, 0);
    assertEq(StableBattle.balanceOf(deployerAddress, knightId), 0);
    assertEq(StableBattle.getKnightsMintedOfCoin(Coin.USDT), 1);
    assertEq(StableBattle.getKnightsMintedOfPool(Pool.AAVE), 1);
    assertEq(StableBattle.getKnightsMintedTotal(), 1);
    assertEq(StableBattle.getKnightsBurnedOfCoin(Coin.USDT), 1);
    assertEq(StableBattle.getKnightsBurnedOfPool(Pool.AAVE), 1);
    assertEq(StableBattle.getKnightsBurnedTotal(), 1);
    assertEq(StableBattle.getTotalKnightSupply(), 0);
  }

  function test_burnKnight_revert_DontOwnItem() public {
    uint256 knightId = StableBattle.mintKnight(Pool.AAVE, Coin.USDT);
    vm.stopPrank();
    vm.prank(vm.addr(2));
    vm.expectRevert("Items Modifiers: Don't Own This Item");
    StableBattle.burnKnight(knightId, 0);
  }

  // Disabled since only knights can be minted in the current version
  /*
  function test_burnKnight_revert_KnightModifiers_WrongKnightId() public {
    uint256 itemId = ?;
    vm.prank(user);
    vm.expectRevert("Knight Modifiers: Wrong Knight Id");
    StableBattle.burnKnight(itemId, 0);
  }
  */

  // TO DO a rather difficult test since it requires a diamond cut
  // to change pool coin compatibility
  /*
  function test_burnKnight_revert_IncompatiblePoolCoin() public {
    uint256 knightId = mintKnight(user, Pool.AAVE, Coin.USDT);
    vm.prank(user);
    vm.expectRevert("MetaModifiers: Incompatible pool coin");
    StableBattle.burnKnight(knightId, 1);
  }
  */
}
