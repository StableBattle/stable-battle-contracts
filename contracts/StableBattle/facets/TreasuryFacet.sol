// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.0;

import { ITreasury } from "../../shared/interfaces/ITreasury.sol";
import { TreasuryStorage as TRSR, TreasuryGetters, TreasuryModifiers } from "../storage/TreasuryStorage.sol";
import { KnightGetters } from "../storage/KnightStorage.sol";
import { ClanGetters } from "../storage/ClanStorage.sol";
import { TournamentGetters } from "../storage/TournamentStorage.sol";
import { ExternalCalls } from "../storage/MetaStorage.sol";

contract TreasuryFacet is ITreasury, 
                          TreasuryModifiers, 
                          TreasuryGetters, 
                          ClanGetters,
                          TournamentGetters,
                          KnightGetters, 
                          ExternalCalls {
  using TRSR for TRSR.State;

  function claimRewards() public {
    uint256 villageAmount = villageAmount();

    //Calculate reward
    uint256 paymentCycles = block.number - lastBlock();
    uint256 reward = rewardPerBlock() * paymentCycles;
    //Assign rewards to village owners
    address[] memory owners = new address[](villageAmount + 1);
    uint256[] memory rewards = new uint256[](villageAmount + 1);
    for (uint v = 0; v < villageAmount; v++){
      owners[v] = villageOwner(v);
      rewards[v] = reward * (100 - castleTax());
    }
    //Assign reward to castle holder clan leader
    owners[villageAmount] = castleHolderAddress();
    rewards[villageAmount] = reward * castleTax();
    //Mint reward tokens
    TRSR.state().lastBlock = block.number;
    SBT().mintBatch(owners, rewards);
  }

  function setTax(uint8 tax) external onlyCastleHolder(castleHolderAddress()) {
    require(tax <= 90, "TreasuryFacet: Can't set a tax above 90%");
    TRSR.state().castleTax = tax;
    emit NewTaxSet(tax);
  }

  function castleHolderAddress() internal view returns(address) {
    return knightOwner(clanLeader(castleHolderClan()));
  }

//Public Getters

  function getCastleTax() public view returns(uint) {
    return castleTax();
  }
  
  function getLastBlock() public view returns(uint) {
    return lastBlock();
  }

  function getRewardPerBlock() public view returns(uint) {
    return rewardPerBlock();
  }
}