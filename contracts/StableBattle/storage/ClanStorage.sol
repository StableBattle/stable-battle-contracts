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
    mapping (uint => uint) joinProposal;
    // character_id => clan_id
    mapping (uint => uint) leaveProposal;
    // address => clan_id => amount
    mapping (address => mapping (uint => uint)) stake;
	}

	bytes32 internal constant STORAGE_SLOT = keccak256("Clan.storage");

	function layout() internal pure returns (Layout storage l) {
		bytes32 slot = STORAGE_SLOT;
		assembly {
			l.slot := slot
		}
	}
}
