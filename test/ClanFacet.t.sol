// SPDX-License-Identifier: None
pragma solidity ^0.8.0;

import { Test } from "forge-std/Test.sol";

import { Pool, Coin, ClanRole } from "../src/StableBattle/Meta/DataStructures.sol";
import { IStableBattle } from "../src/StableBattle/Meta/IStableBattle.sol";
import { IBEER } from "../src/BEER/IBEER.sol";
import { ISBV } from "../src/SBV/ISBV.sol";
import { IClanEvents } from "../src/StableBattle/Facets/Clan/IClan.sol";

import { TestSetups } from "../test/TestSetups.s.sol";
import { SetupAddressLib } from "../src/StableBattle/Init&Updates/SetupAddressLib.sol";

contract ClanFacetTest is IClanEvents, Test, TestSetups {
  IStableBattle StableBattle;
  IBEER BEER;
  ISBV SBV;
  uint256 constant amount = 10;
  address[] users = new address[](amount);
  uint256[] knights = new uint256[](amount);
  uint256 goerliFork;
  
  function setUp() public {
    goerliFork = vm.createSelectFork(goerliForkURL, 8455800);
    vm.startBroadcast(deployerAddress);
    (StableBattle, BEER, SBV) = deployStableBattle(deployerAddress, 0);
    vm.stopBroadcast();
    (users, knights) = mintKnights_AAVE_USDT(StableBattle, amount);
  }

  function test_createClan(uint256 i) public {
    vm.assume(i >= 0 && i < amount);
    uint256 knight = knights[i];
    address user = users[i];
    // Check before state
    uint256 nextClanId = StableBattle.getClansInTotal() + 1;
    assertEq(StableBattle.getClanLeader(nextClanId), 0);
    assertEq(StableBattle.getClanTotalMembers(nextClanId), 0);
    assertEq(StableBattle.getClanStake(nextClanId), 0);
    assertEq(StableBattle.getClanLevel(nextClanId), 1);
    assertEq(StableBattle.getClanName(nextClanId), "");
    assertEq(StableBattle.getClanNameTaken("Test Clan"), false);
    // Check events
    vm.expectEmit(address(StableBattle));
    emit ClanCreated(nextClanId, knight);
    vm.expectEmit(address(StableBattle));
    emit ClanNewName(nextClanId, "Test Clan");
    vm.expectEmit(address(StableBattle));
    emit ClanKnightJoined(nextClanId, knight);
    vm.expectEmit(address(StableBattle));
    emit ClanNewRole(nextClanId, knight, ClanRole.OWNER);
    // Perform action
    vm.prank(user);
    uint256 clan = StableBattle.createClan(knight, "Test Clan");
    // Check after state
    assertEq(clan, nextClanId);
    assertEq(StableBattle.getClansInTotal(), nextClanId);
    assertEq(StableBattle.getClanLeader(clan), knight);
    assertEq(uint8(StableBattle.getClanRole(knight)), uint8(ClanRole.OWNER));
    assertEq(StableBattle.getClanTotalMembers(clan), 1);
    assertEq(StableBattle.getClanStake(clan), 0);
    assertEq(StableBattle.getClanLevel(clan), 1);
    assertEq(StableBattle.getClanName(clan), "Test Clan");
    assertEq(StableBattle.getClanNameTaken("Test Clan"), true);
  }

  function test_revert_createClan_ItemsModifiers_DontOwnThisItem() public {
    uint256 knight = knights[0];
    address user = users[1];
    vm.prank(user);
    vm.expectRevert("Items Modifiers: Don't Own This Item");
    StableBattle.createClan(knight, "Test Clan");
  }

  // Inactive since we don't have a way to mint something other than knights
  /*
  function test_revert_createClan_KnightModifiers_WrongKnightId() public {
    uint256 knight = knights[0];
    address user = users[1];
    vm.prank(user);
    vm.expectRevert("Knight Modifiers: Wrong Knight Id");
    StableBattle.createClan(knight, "Test Clan");
  }
  */

  function test_revert_createClan_KnightModifiers_KnightInSomeClan() public {
    uint256 knight = knights[0];
    address user = users[0];
    vm.prank(user);
    StableBattle.createClan(knight, "Test Clan");
    vm.prank(user);
    vm.expectRevert("Knight Modifiers: Knight In Some Clan");
    StableBattle.createClan(knight, "Test Clan 2");
  }

  // Inactive in current version, activate later
  /*
  function test_revert_createClan_ClanModifiers_KnightOnClanActivityCooldown() public {
    uint256 knight = knights[0];
    address user = users[0];
    vm.prank(user);
    StableBattle.createClan(knight, "Test Clan");
    vm.prank(user);
    vm.expectRevert("Clan Modifiers: Knight On Clan Activity Cooldown");
  }
  */

  function test_revert_createClan_ClanModifiers_ClanNameTaken() public {
    vm.prank(users[0]);
    StableBattle.createClan(knights[0], "Test Clan");
    vm.prank(users[1]);
    vm.expectRevert("Clan Modifiers: Clan Name Taken");
    StableBattle.createClan(knights[1], "Test Clan");
  }

  function test_revert_createClan_ClanModifiers_ClanNameTooShort() public {
    vm.prank(users[0]);
    vm.expectRevert("Clan Modifiers: Clan Name Wrong Length");
    StableBattle.createClan(knights[0], "");
    vm.prank(users[0]);
    vm.expectRevert("Clan Modifiers: Clan Name Wrong Length");
    StableBattle.createClan(knights[0], "123456789_123456789_123456789_123456789_");
  }
}
