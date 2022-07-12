// SPDX-License-Identifier: Unlicensed

pragma solidity ^0.8.0;

enum proposalType {
  NONE,
  JOIN,
  LEAVE,
  INVITE
}

struct Clan {
  uint256 owner;
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
    mapping (uint256 => mapping(uint256 => proposalType)) proposal;
    // knightId => clanId
    mapping (uint256 => uint256) joinProposal;
    // knightId => clanId
    mapping (uint256 => uint256) leaveProposal;
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

  function clanOwner(uint clanId) internal view virtual returns(uint256) {
    return ClanStorage.state().clan[clanId].owner;
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

  function clanLevelThresholds(uint newLevel) internal view virtual returns (uint) {
    return ClanStorage.state().levelThresholds[newLevel];
  }

  function clanMaxLevel() internal view virtual returns (uint) {
    return ClanStorage.state().levelThresholds.length;
  }

  function joinProposal(uint256 knightId) internal view virtual returns (uint) {
    return ClanStorage.state().joinProposal[knightId];
  }

  function leaveProposal(uint256 knightId) internal view virtual returns (uint) {
    return ClanStorage.state().leaveProposal[knightId];
  }

  function proposal(uint256 knightId, uint256 clanId) internal virtual returns(proposalType) {
    return ClanStorage.state().proposal[knightId][clanId];
  }

  function clansInTotal() internal view virtual returns(uint256) {
    return ClanStorage.state().clansInTotal;
  }
}

abstract contract ClanModifiers {
  function clanExists(uint256 clanId) internal view returns(bool) {
    return ClanStorage.state().clan[clanId].owner != 0;
  }

  modifier ifClanExists(uint256 clanId) {
    require(clanExists(clanId),
      "ClanModifiers: This clan doesn't exist");
    _;
  }
}
