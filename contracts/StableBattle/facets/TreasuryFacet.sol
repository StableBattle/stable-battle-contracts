// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.10;

import {AppStorage} from "../libraries/LibAppStorage.sol";
import {ISBT} from "../../shared/interfaces/ISBT.sol";

contract Treasury {

  AppStorage internal s;

  uint reward_per_block;
  //character_id => amount
  mapping (uint => uint) rewards;
  uint last_block;

  //Called on execution of mint or burn in SBV contract
  function onVillageMint(uint amount) public {
    s.villageAmount = amount;
  }

  //Called on transfer and transferFrom in SBV contract
  function onVillageTransfer(uint village, address beneficiary) public {
    require (s.SBV.ownerOf(village) == msg.sender, 
            "Only village owner can change a beneficiary");
    s.beneficiaries[village] = beneficiary;
    emit beneficiaryUpdated (village, beneficiary);
  }
  //!!! Check the difference between gas costs with(out) calls to SBV !!!
  function claim_rewards() public {
    uint payment_cycles = block.number - s.last_block;
    //Assign rewards to village owners
    //for (for v = 0; v < Villages.TotalSupply(); v++){
    //    SBT._mint(Villages.ownerOf(v), reward_per_block * payment_cycles * castle_tax);
    //}
    for (uint i = 0; i < s.villageAmount; i++){
      s.SBT.mint(s.beneficiaries[i], s.reward_per_block * payment_cycles * s.castle_tax);
    }
    //Assign reward to castle holder clan leader
    s.SBT.mint(s.Items.ownerOf(s.clan[s.CastleHolder].owner), s.reward_per_block * payment_cycles * (100 - s.castle_tax));

    s.last_block = block.number;
  }

  event beneficiaryUpdated (uint village, address beneficiary);
}