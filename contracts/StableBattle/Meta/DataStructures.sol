// SPDX-License-Identifier: Unlicensed

pragma solidity ^0.8.0;

enum Pool { NONE, TEST, AAVE }

enum Coin { NONE, TEST, USDT, USDC, EURS }

struct Knight {
  Pool pool;
  Coin coin;
  address owner;
  uint256 inClan;
}

enum gearSlot { NONE, WEAPON, SHIELD, HELMET, ARMOR, PANTS, SLEEVES, GLOVES, BOOTS, JEWELRY, CLOAK }

enum Proposal { NONE, JOIN, LEAVE, INVITE }

struct Clan {
  uint256 leader;
  uint256 stake;
  uint totalMembers;
  uint level;
}

enum Role { NONE, ADMIN }

enum ClanRole { NONE, OWNER, ADMIN, MOD }