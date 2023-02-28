// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.10;

interface ConfigEvents {
  event ClanNewConfig(
    uint[] levelThresholds,
    uint[] maxMembersPerLevel,
    uint clanActivityCooldownConst,
    uint clanKickCoolDownConst,
    uint clanStakeWithdrawCooldownConst);
}