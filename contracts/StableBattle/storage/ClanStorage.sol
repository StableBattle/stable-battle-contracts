// SPDX-License-Identifier: Unlicensed

pragma solidity ^0.8.0;

enum Proposal {
  NONE,
  JOIN,
  LEAVE,
  INVITE
}

struct Clan {
  uint256 leader;
  uint256 stake;
  uint totalMembers;
  uint level;
}

library ClanStorage {
  struct State {
    uint MAX_CLAN_MEMBERS;
    uint[] levelThresholds;
    // clanId => Clan
    mapping(uint256 => Clan) clan;
    // knightId => clanId => proposalType
    mapping (uint256 => mapping(uint256 => Proposal)) proposal;
    // address => clanId => amount
    mapping (address => mapping (uint => uint256)) stake;
    
    uint256 clansInTotal;
  }

  bytes32 internal constant STORAGE_SLOT = keccak256("Clan.storage");

  function state() internal pure returns (State storage l) {
    bytes32 slot = STORAGE_SLOT;
    assembly {
      l.slot := slot
    }
  }
}

abstract contract ClanGetters {
  function clanInfo(uint clanId) internal view virtual returns(Clan memory) {
    return ClanStorage.state().clan[clanId];
  }

  function clanLeader(uint clanId) internal view virtual returns(uint256) {
    return ClanStorage.state().clan[clanId].leader;
  }

  function clanTotalMembers(uint clanId) internal view virtual returns(uint) {
    return ClanStorage.state().clan[clanId].totalMembers;
  }
  
  function clanStake(uint clanId) internal view virtual returns(uint256) {
    return ClanStorage.state().clan[clanId].stake;
  }

  function clanLevel(uint clanId) internal view virtual returns(uint) {
    return ClanStorage.state().clan[clanId].level;
  }

  function stakeOf(address benefactor, uint clanId) internal view virtual returns(uint256) {
    return ClanStorage.state().stake[benefactor][clanId];
  }

  function clanLevelThreshold(uint level) internal view virtual returns (uint) {
    return ClanStorage.state().levelThresholds[level];
  }

  function clanMaxLevel() internal view virtual returns (uint) {
    return ClanStorage.state().levelThresholds.length;
  }

  function proposal(uint256 knightId, uint256 clanId) internal view virtual returns(Proposal) {
    return ClanStorage.state().proposal[knightId][clanId];
  }

  function clansInTotal() internal view virtual returns(uint256) {
    return ClanStorage.state().clansInTotal;
  }
}

abstract contract ClanModifiers {
  function clanExists(uint256 clanId) internal view returns(bool) {
    return ClanStorage.state().clan[clanId].leader != 0;
  }

  modifier ifClanExists(uint256 clanId) {
    require(clanExists(clanId),
      "ClanModifiers: This clan doesn't exist");
    _;
  }

  function isClanLeader(uint256 knightId, uint256 clanId) internal view returns(bool) {
    return ClanStorage.state().clan[clanId].leader == knightId;
  }

  modifier ifIsClanLeader(uint256 knightId, uint clanId) {
    require(isClanLeader(knightId, clanId), 
      "ClanModifiers: This knight is doesn't own this clan");
    _;
  }

  function isNotClanLeader(uint256 knightId, uint256 clanId) internal view returns(bool) {
    return ClanStorage.state().clan[clanId].leader != knightId;
  }

  modifier ifIsNotClanLeader(uint256 knightId, uint clanId) {
    require(isNotClanLeader(knightId, clanId), 
      "ClanModifiers: This knight is already owns this clan");
    _;
  }
}
