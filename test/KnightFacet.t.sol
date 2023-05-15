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
import { console2 } from  "forge-std/console2.sol";

contract KnightFacetTest is Test, DeployStableBattle {
  IStableBattle StableBattle;
  IBEER BEER;
  ISBV SBV;
  IERC20 USDT;
  uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
  address deployerAddress = vm.envAddress("PUBLIC_KEY");
  string goerliForkURL = vm.envString("GOERLI_INFURA_URL");
  uint256 goerliFork;
  
  function setUp() public {
    goerliFork = vm.createSelectFork(goerliForkURL);
    vm.startBroadcast(deployerPrivateKey);
    (StableBattle, BEER, SBV) = deployStableBattle(deployerAddress, 0);
    USDT = IERC20(SetupAddressLib.getCoinAddress(Coin.USDT));

  }

  function test_approve_USDT() public {
    USDT.approve(address(StableBattle), StableBattle.getKnightPrice(Coin.USDT));
    assertEq(USDT.allowance(deployerAddress, address(StableBattle)), StableBattle.getKnightPrice(Coin.USDT)); 
  }

  function test_mintKnight_revert_poolCoinCompatibility() public {
    vm.expectRevert("MetaModifiers: Incompatible pool coin");
    StableBattle.mintKnight(Pool.NONE, Coin.NONE);
  }

  function test_mintKnight_revert_insufficientAllowance() public {
    vm.expectRevert("KnightFacet: Insufficient allowance");
    StableBattle.mintKnight(Pool.AAVE, Coin.USDT);
  }

  function test_mintKnight() public returns(uint256 knightId) {
    USDT.approve(address(StableBattle), StableBattle.getKnightPrice(Coin.USDT));
    knightId = StableBattle.mintKnight(Pool.AAVE, Coin.USDT);
    assertEq(StableBattle.balanceOf(deployerAddress, knightId), 1);
    assertEq(StableBattle.getKnightsMintedOfCoin(Coin.USDT), 1);
    assertEq(StableBattle.getKnightsMintedOfPool(Pool.AAVE), 1);
    assertEq(StableBattle.getKnightsMintedTotal(), 1);
    assertEq(StableBattle.getTotalKnightSupply(), 1);
  }

  function test_burnKnight_revert_DontOwnItem() public {
    vm.expectRevert("Items Modifiers: Don't Own This Item");
    StableBattle.burnKnight(type(uint256).max, 0);
  }

  function test_burnKnight() public {
    uint256 knightId = test_mintKnight();
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
}
