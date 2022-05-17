// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.0;

contract ClanFacet {
  
    event ClanCreated(uint clan_id, uint chracter_id);
    event ClanDissloved(uint clan_id, uint chracter_id);
    event CharacterAskedToJoin(uint clan_id, uint chracter_id);
    event MemberAdded(uint clan_id, uint character_id);
    event CharacterAskedToLeave(uint clan_id, uint chracter_id);
    event MemberLeft(address something);
    // clan_id => character
    mapping(uint => uint) Clan_owners;
    //character_id => clan_id
    mapping(uint => uint) Owns_a_clan;
    // clan_id => character_id
    mapping(uint => uint[]) Clan_members;
    //clan_id => number
    mapping(uint => uint) Total_members;
    // character_id => bool
    mapping (uint => bool) character_in_a_clan;
    // character_id => clan_id
    mapping (uint => uint) join_proposal;

    function Create(uint charater_id) external returns (uint clan_id) {
      require(IERC1155.balanceOf(msg.sender, charater_id) == 1,
             "Only knights can create a clan");
      require(Owns_a_clan[charater_id] > 0, "Only one clan per character")
      Owns_a_clan[charater_id] = clan_id;
      Clan_owners[clan_id] = character_id;
      Clan_members[clan_id] = [charater_id];
      Total_members[clan_id]++;
      clan_id++;
      emit ClanCreated(clan_id, character_id)
    }

    function Dissolve(uint character_id, uint clan_id) external {
      require(Owns_a_clan[character_id], "This character doesn't lead a clan");
      Owns_a_clan[charater_id] = 0;
      delete Clan_members[clan_id];
      Total_members[clan_id] = 0;
      emit ClanDissloved(clan_id, character_id)
    }

    function stake(uint clan_id, uint amount) external {
      SBT._stake(uint clan_id, uint amount);
    }

    function withdraw() external {}

    function join(uint character_id, uint clan_id) external {
      require(IERC1155.balanceOf(msg.sender, charater_id) == 1,
              "Only knights can join a clan");
      require(!character_in_a_clan[character_id], 
              "Character can only join one clan");
      join_proposals[character_id] = clan_id;
      emit CharacterAskedToJoin(clan_id, chracter_id);
    }

    function leave() external {
      require(IERC1155.balanceOf(msg.sender, charater_id) == 1,
              "Only knights can join a clan");
      require(character_in_a_clan[character_id], 
              "Character can only join one clan");
      leave_proposals[character_id] = clan_id;
      emit CharacterAskedToLeave(clan_id, chracter_id);
    }

    function accept_join() external {}

    function refusejoin() external {}

    function acceptleave() external {}

    function refuseleave() external {}

    function supportsInterface(bytes4 _interfaceID) external view returns (bool) {}
}
