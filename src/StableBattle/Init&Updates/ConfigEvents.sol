// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.0;

interface ConfigEvents {
  event AddressesNewConfig(
    address BEER,
    address SBV,
    address AAVE,
    address[] coins,
    address[] acoins,
    address[] pools);

  event ClanNewConfig(
    uint[] levelThresholds,
    uint[] maxMembersPerLevel,
    uint clanActivityCooldownConst,
    uint clanKickCoolDownConst,
    uint clanStakeWithdrawCooldownConst);
}