// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.10;

import { AppStorage } from "../libraries/LibAppStorage.sol";

contract Treasury {

  AppStorage internal s;

  function claim_rewards() public {
    uint payment_cycles = block.number - s.last_block;
    //Assign rewards to village owners
    uint totalSupply = s.SBV.totalSupply();
    address[] memory owners = new address[](totalSupply);
    uint256[] memory rewards = new uint256[](totalSupply);
    for (uint v = 0; v < totalSupply; v++){
      owners[v] = s.SBV.ownerOf(v);
      rewards[v] = s.reward_per_block * payment_cycles * s.castle_tax;
    }
    s.SBT.mintBatch(owners, rewards);
    //Assign reward to castle holder clan leader
    s.SBT.mint(s.Items.ownerOfKnight(s.clan[s.CastleHolder].owner), s.reward_per_block * payment_cycles * (100 - s.castle_tax));

    s.last_block = block.number;
  }

  event beneficiaryUpdated (uint village, address beneficiary);
}