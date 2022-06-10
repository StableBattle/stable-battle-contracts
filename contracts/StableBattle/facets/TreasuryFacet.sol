// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.10;

import { AppStorage } from "../libraries/LibAppStorage.sol";

contract TreasuryFacet {

  AppStorage internal s;

  function claim_rewards() public {
    uint payment_cycles = block.number - s.last_block;
    //Assign rewards to village owners
    uint villageAmount = s.SBV.totalSupply();
    address[] memory owners = new address[](villageAmount + 1);
    uint256[] memory rewards = new uint256[](villageAmount + 1);
    for (uint v = 0; v < villageAmount; v++){
      owners[v] = s.SBV.ownerOf(v);
      rewards[v] = s.reward_per_block * payment_cycles * s.castle_tax;
    }
    //Assign reward to castle holder clan leader
    owners[villageAmount] = s.Items.ownerOfKnight(s.clan[s.CastleHolder].owner);
    rewards[villageAmount] = s.reward_per_block * payment_cycles * (100 - s.castle_tax);
    //Mint reward tokens
    s.SBT.mintBatch(owners, rewards);
    s.last_block = block.number;
  }

  event beneficiaryUpdated (uint village, address beneficiary);
}