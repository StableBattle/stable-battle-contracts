// SPDX-License-Identifier: Unlicensed

pragma solidity ^0.8.0;

import { Pool, Coin, ClanRole } from "../Meta/DataStructures.sol";
import { IERC20Mintable } from "../Meta/IERC20Mintable.sol";
import { IStableBattle } from "../Meta/IStableBattle.sol";
import { IBEER } from "../../BEER/IBEER.sol";
import { IPool } from "@aave/core-v3/contracts/interfaces/IPool.sol";
import { AToken } from "@aave/core-v3/contracts/protocol/tokenization/AToken.sol";
import { Strings } from "@openzeppelin/contracts/utils/Strings.sol";
import { ERC1155Receiver } from "@openzeppelin/contracts/token/ERC1155/utils/ERC1155Receiver.sol";

contract PopulateEvents is ERC1155Receiver {
  IERC20Mintable immutable USDT;
  IStableBattle immutable SB;
  IBEER immutable BEER;
  IPool immutable AAVE;
  AToken immutable AUSDT;
  uint256 constant numberOfKnights = 32;
  uint256 constant numberOfClans = 3;
  uint256[] knightIds = new uint256[](numberOfKnights);
  uint256[] clanIds = new uint256[](numberOfClans);

  constructor(
    address _USDT,
    address _SB,
    address _BEER,
    address _AAVE,
    address _AUSDT
  ) {
    USDT = IERC20Mintable(_USDT);
    SB = IStableBattle(_SB);
    BEER = IBEER(_BEER);
    AAVE = IPool(_AAVE);
    AUSDT = AToken(_AUSDT);
  }

  function populateEvents() external {
    //Mint knights
    USDT.transferFrom(msg.sender, address(this), numberOfKnights * 1000 * 10 ** 6);
    USDT.approve(address(SB), numberOfKnights * 1000 * 10 ** 6);
    for (uint256 i = 0; i < numberOfKnights; i++) {
      knightIds[i] = SB.mintKnight(Pool.AAVE, Coin.USDT);
    }
    //Form clans
    for (uint256 i = 0; i < numberOfClans; i++) {
    //string memory name = string.concat("Test string", Strings.toString(i));
      string memory name = i == 0 ? "Test clan 1" : i == 1 ? "Test clan 2" : "Test clan 3";
      clanIds[i] = SB.createClan(knightIds[i], name);
    }
    //Level up clans
    BEER.mint(address(this), 300000 * 10 ** 18);
    //Level up clan 2
    SB.clanStake(clanIds[1],  50000 * 10 ** 18);
    //Level up clan 3
    SB.clanStake(clanIds[2], 250000 * 10 ** 18);
    //Bulk join in clan 1 and assign roles
    // Knights from 3 to 7 to join clan 1
    for (uint256 i = 0; i < 5; i++) {
      SB.joinClan(knightIds[numberOfClans + i], clanIds[0]);
      SB.approveJoinClan(knightIds[numberOfClans + i], clanIds[0], knightIds[0]);
    }
    SB.setClanRole(clanIds[0], knightIds[numberOfClans + 0], ClanRole.ADMIN, knightIds[0]);
    SB.setClanRole(clanIds[0], knightIds[numberOfClans + 1], ClanRole.MOD, knightIds[0]);
    SB.setClanRole(clanIds[0], knightIds[numberOfClans + 2], ClanRole.MOD, knightIds[0]);
    //Bulk join in clan 2 and assign roles
    // Knights from 8 to 17 to join clan 2
    for (uint256 i = 5; i < 15; i++) {
      SB.joinClan(knightIds[numberOfClans + i], clanIds[1]);
      SB.approveJoinClan(knightIds[numberOfClans + i], clanIds[1], knightIds[1]);
    }
    SB.setClanRole(clanIds[1], knightIds[numberOfClans + 5], ClanRole.ADMIN, knightIds[1]);
    SB.setClanRole(clanIds[1], knightIds[numberOfClans + 6], ClanRole.ADMIN, knightIds[1]);
    SB.setClanRole(clanIds[1], knightIds[numberOfClans + 7], ClanRole.ADMIN, knightIds[1]);
    SB.setClanRole(clanIds[1], knightIds[numberOfClans + 8], ClanRole.MOD, knightIds[1]);
    SB.setClanRole(clanIds[1], knightIds[numberOfClans + 9], ClanRole.MOD, knightIds[1]);
    SB.setClanRole(clanIds[1], knightIds[numberOfClans + 10], ClanRole.MOD, knightIds[1]);
    SB.setClanRole(clanIds[1], knightIds[numberOfClans + 11], ClanRole.MOD, knightIds[1]);
    //Bulk join in clan 3 and assign roles
    // Knights from 18 to 28 to join clan 3
    for (uint256 i = 15; i < 26; i++) {
      SB.joinClan(knightIds[numberOfClans + i], clanIds[2]);
      SB.approveJoinClan(knightIds[numberOfClans + i], clanIds[2], knightIds[2]);
    }
    SB.setClanRole(clanIds[2], knightIds[numberOfClans + 15], ClanRole.ADMIN, knightIds[2]);
    SB.setClanRole(clanIds[2], knightIds[numberOfClans + 16], ClanRole.ADMIN, knightIds[2]);
    SB.setClanRole(clanIds[2], knightIds[numberOfClans + 17], ClanRole.MOD, knightIds[2]);
    SB.setClanRole(clanIds[2], knightIds[numberOfClans + 18], ClanRole.MOD, knightIds[2]);
    SB.setClanRole(clanIds[2], knightIds[numberOfClans + 19], ClanRole.MOD, knightIds[2]);
    SB.setClanRole(clanIds[2], knightIds[numberOfClans + 20], ClanRole.MOD, knightIds[2]);
    SB.setClanRole(clanIds[2], knightIds[numberOfClans + 21], ClanRole.MOD, knightIds[2]);
    //Add a few more events
    SB.leaveClan(knightIds[numberOfClans + 22], clanIds[2]);
    SB.kickFromClan(knightIds[numberOfClans + 23], clanIds[2], knightIds[2]);
    SB.joinClan(knightIds[numberOfClans + 26], clanIds[2]);
    SB.withdrawJoinClan(knightIds[numberOfClans + 26], clanIds[2]);
    SB.joinClan(knightIds[numberOfClans + 26], clanIds[2]);
    SB.dismissJoinClan(knightIds[numberOfClans + 26], clanIds[2], knightIds[2]);
    SB.joinClan(knightIds[numberOfClans + 27], clanIds[2]);
    SB.joinClan(knightIds[numberOfClans + 28], clanIds[2]);
    SB.clanWithdrawRequest(clanIds[2], 100000 * 10 ** 18);
  //SB.debugSetWithdrawalCooldown(clanIds[2], address(this), 0);
    SB.clanWithdraw(clanIds[2], 100000 * 10 ** 18);
    //Bump siege reward
    uint256 bumpAmount = 1000 * 10 ** 6;
    USDT.transferFrom(msg.sender, address(this), bumpAmount);
    USDT.approve(address(AAVE), bumpAmount);
    AAVE.supply(address(USDT), bumpAmount, address(SB), 0);
    //Claim siege reward
    uint256 siegeReward = SB.getSiegeYield();
    SB.setClanName(clanIds[1], "New name for clan 2");
    SB.setSiegeWinner(clanIds[0], knightIds[0], address(this));
    SB.claimSiegeReward(address(this), siegeReward / 2);
    SB.burnKnight(knightIds[0], knightIds[3]);
    SB.abandonClan(clanIds[0], knightIds[3]);
    //Transfer knights back to me
    uint256[] memory knightIdsBack = new uint256[](numberOfKnights - 1);
    uint256[] memory knightAmounts = new uint256[](numberOfKnights - 1);
    for (uint256 i = 0; i < numberOfKnights - 1; i++) {
      knightIdsBack[i] = knightIds[i + 1];
      knightAmounts[i] = 1;
    }
    SB.safeBatchTransferFrom(address(this), msg.sender, knightIdsBack, knightAmounts, "");
  }

  function onERC1155Received(
    address operator,
    address from,
    uint256 id,
    uint256 value,
    bytes calldata data
  ) external returns (bytes4) {
    return bytes4(keccak256("onERC1155Received(address,address,uint256,uint256,bytes)"));
  }

  function onERC1155BatchReceived(
    address operator,
    address from,
    uint256[] calldata ids,
    uint256[] calldata values,
    bytes calldata data
  ) external returns (bytes4) {
    return bytes4(keccak256("onERC1155BatchReceived(address,address,uint256[],uint256[],bytes)"));
  }
}