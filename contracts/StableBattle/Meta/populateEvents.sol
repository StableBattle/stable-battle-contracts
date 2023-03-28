// SPDX-License-Identifier: Unlicensed

pragma solidity ^0.8.0;

import { Pool, Coin, ClanRole } from "../Meta/DataStructures.sol";
import { IERC20Mintable } from "../Meta/IERC20Mintable.sol";
import { IStableBattle } from "../Meta/IStableBattle.sol";
import { IBEER } from "../../BEER/IBEER.sol";
import { IPool } from "@aave/core-v3/contracts/interfaces/IPool.sol";
import { AToken } from "@aave/core-v3/contracts/protocol/tokenization/AToken.sol";


contract PopulateEvents {
  IERC20Mintable immutable USDT;
  IStableBattle immutable SB;
  IBEER immutable BEER;
  IPool immutable AAVE;
  AToken immutable AUSDT;

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

  function populateEvents(uint256 knights, uint256 clans) external {
    //Mint knights
    USDT.mint(address(this), knights * 1000 * 10 ** 6);
    uint256[] memory knightIds = new uint256[](knights);
    for (uint256 i = 0; i < knights; i++) {
      knightIds[i] = SB.mintKnight(Pool.AAVE, Coin.USDT);
    }
    //Form clans
    uint256[] memory clanIds = new uint256[](clans);
    for (uint256 i = 0; i < clans; i++) {
      string memory name = string(abi.encodePacked("Test Clan ", i));
      clanIds[i] = SB.createClan(knightIds[i], name);
    }
    //Level up clans
    BEER.mint(address(this), 300000 * 10 ** 18);
    //Level up clan 2
    SB.clanStake(clanIds[1],  50000 * 10 ** 18);
    //Level up clan 3
    SB.clanStake(clanIds[2], 250000 * 10 ** 18);
    //Bulk join in clan 1 and assign roles
    for (uint256 i = 0; i < 5; i++) {
      SB.joinClan(clanIds[0], knightIds[clans + i]);
      SB.approveJoinClan(knightIds[clans + i], clanIds[0], knightIds[0]);
    }
    SB.setClanRole(clanIds[1], knightIds[clans + 0], ClanRole.ADMIN, knightIds[0]);
    SB.setClanRole(clanIds[1], knightIds[clans + 1], ClanRole.MOD, knightIds[0]);
    SB.setClanRole(clanIds[1], knightIds[clans + 2], ClanRole.MOD, knightIds[0]);
    //Bulk join in clan 2 and assign roles
    for (uint256 i = 0; i < 10; i++) {
      SB.joinClan(clanIds[1], knightIds[clans + i]);
      SB.approveJoinClan(knightIds[clans + i], clanIds[1], knightIds[2]);
    }
    SB.setClanRole(clanIds[1], knightIds[clans + 5], ClanRole.ADMIN, knightIds[0]);
    SB.setClanRole(clanIds[1], knightIds[clans + 6], ClanRole.ADMIN, knightIds[0]);
    SB.setClanRole(clanIds[1], knightIds[clans + 7], ClanRole.ADMIN, knightIds[0]);
    SB.setClanRole(clanIds[1], knightIds[clans + 8], ClanRole.MOD, knightIds[0]);
    SB.setClanRole(clanIds[1], knightIds[clans + 9], ClanRole.MOD, knightIds[0]);
    SB.setClanRole(clanIds[1], knightIds[clans + 10], ClanRole.MOD, knightIds[0]);
    SB.setClanRole(clanIds[1], knightIds[clans + 11], ClanRole.MOD, knightIds[0]);
    //Bulk join in clan 3 and assign roles
    for (uint256 i = 0; i < 5; i++) {
      SB.joinClan(clanIds[2], knightIds[clans + i]);
      SB.approveJoinClan(knightIds[clans + i], clanIds[2], knightIds[0]);
    }
    SB.setClanRole(clanIds[1], knightIds[clans + 15], ClanRole.ADMIN, knightIds[0]);
    SB.setClanRole(clanIds[1], knightIds[clans + 16], ClanRole.ADMIN, knightIds[0]);
    SB.setClanRole(clanIds[1], knightIds[clans + 17], ClanRole.MOD, knightIds[0]);
    SB.setClanRole(clanIds[1], knightIds[clans + 18], ClanRole.MOD, knightIds[0]);
    SB.setClanRole(clanIds[1], knightIds[clans + 19], ClanRole.MOD, knightIds[0]);
    SB.setClanRole(clanIds[1], knightIds[clans + 20], ClanRole.MOD, knightIds[0]);
    SB.setClanRole(clanIds[1], knightIds[clans + 21], ClanRole.MOD, knightIds[0]);
    //Add a few more events
    SB.leaveClan(knightIds[clans + 22], clanIds[2]);
    SB.kickFromClan(knightIds[clans + 23], clanIds[2], knightIds[2]);
    SB.joinClan(knightIds[clans + 26], clanIds[2]);
    SB.withdrawJoinClan(knightIds[clans + 26], clanIds[2]);
    SB.joinClan(knightIds[clans + 26], clanIds[2]);
    SB.dismissJoinClan(knightIds[clans + 26], clanIds[2], knightIds[2]);
    SB.joinClan(knightIds[clans + 27], clanIds[2]);
    SB.joinClan(knightIds[clans + 28], clanIds[2]);
    SB.clanWithdrawRequest(clanIds[2], 100000 * 10 ** 18);
    SB.debugSetWithdrawalCooldown(clanIds[2], address(this), 0);
    SB.clanWithdraw(clanIds[2], 100000 * 10 ** 18);
    //Bump siege reward
    USDT.mint(address(this), 1000 * 10 ** 6);
    AAVE.supply(address(USDT), 1000 * 10 ** 6, address(SB), 0);
    //Claim siege reward
    uint256 siegeReward = SB.getSiegeYield();
    SB.setClanName(clanIds[1], "New name for clan 2");
    SB.setSiegeWinner(clanIds[0], knightIds[0], address(this));
    SB.claimSiegeReward(address(this), siegeReward / 2);
    SB.burnKnight(knightIds[0], knightIds[3]);
    SB.abandonClan(clanIds[0], knightIds[3]);
    //Transfer knights back to me
    knightIdsBack = new uint256[](knights - 1);
    knightAmounts = new uint256[](knights - 1);
    for (uint256 i = 0; i < knights - 1; i++) {
      knightIdsBack[i] = knightIds[i + 1];
      knightAmounts[i] = 1;
    }
    SB.safeBatchTransferFrom(address(this), address(this), knightIdsBack, knightAmounts, "");
  }

  function transferKnight(uint256 knightId, address to) external {
    SB.safeBatchTransferFrom(address(this), to, knightIds, 1, "");
  }
}