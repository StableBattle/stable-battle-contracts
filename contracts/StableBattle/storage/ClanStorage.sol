// SPDX-License-Identifier: Unlicensed

pragma solidity ^0.8.0;

struct Clan {
  uint256 owner;
  uint totalMembers;
  uint stake;
  uint level;
}

library ClanStorage {
	struct Layout {
    uint MAX_CLAN_MEMBERS;
    uint[] levelThresholds;
    // clan_id => clan
    mapping(uint => Clan) clan;
    // character_id => clan_id
    mapping (uint256 => uint) joinProposal;
    // character_id => clan_id
    mapping (uint256 => uint) leaveProposal;
    // address => clan_id => amount
    mapping (address => mapping (uint => uint256)) stake;
	}

	bytes32 internal constant STORAGE_SLOT = keccak256("Clan.storage");

	function layout() internal pure returns (Layout storage l) {
		bytes32 slot = STORAGE_SLOT;
		assembly {
			l.slot := slot
		}
	}

  function clanCheck(uint clanId) internal view returns(Clan memory) {
    return layout().clan[clanId];
  }

  function clanOwner(uint clanId) internal view returns(uint256) {
    return layout().clan[clanId].owner;
  }

  function clanTotalMembers(uint clanId) internal view returns(uint) {
    return layout().clan[clanId].totalMembers;
  }
  
  function clanStake(uint clanId) internal view returns(uint256) {
    return layout().clan[clanId].stake;
  }

  function clanLevel(uint clanId) internal view returns(uint) {
    return layout().clan[clanId].level;
  }

  function stakeOf(address benefactor, uint clanId) internal view returns(uint256) {
    return layout().stake[benefactor][clanId];
  }

  function clanLevelThresholds(uint newLevel) internal view returns (uint) {
    return layout().levelThresholds[newLevel];
  }

  function clanMaxLevel() internal view returns (uint) {
    return layout().levelThresholds.length;
  }

  function joinProposal(uint256 knightId) internal view returns (uint) {
    return layout().joinProposal[knightId];
  }

  function leaveProposal(uint256 knightId) internal view returns (uint) {
    return layout().leaveProposal[knightId];
  }
}
