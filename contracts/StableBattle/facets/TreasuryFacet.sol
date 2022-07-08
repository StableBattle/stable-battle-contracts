// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.0;

import { MetaStorage as META } from "../storage/MetaStorage.sol";
import { TreasuryStorage as TRSR, TreasuryModifiers } from "../storage/TreasuryStorage.sol";
import { KnightStorage as KNHT } from "../storage/KnightStorage.sol";
import { ClanStorage as CLAN } from "../storage/ClanStorage.sol";
import { TournamentStorage as TMNT } from "../storage/TournamentStorage.sol";
import { ITreasury } from "../../shared/interfaces/ITreasury.sol";

contract TreasuryFacet is ITreasury, TreasuryModifiers {
  using TRSR for TRSR.Layout;

  function CastleHolder() private view returns(address) {
  //Find owner of castle holding clan
    //Find the castle holding clan
    uint CastleHoldingClan = TMNT.castleHolder();
    //Find the knight that leads that clan
    uint CastleHoldingClanLeader = CLAN.clanOwner(CastleHoldingClan);
    //Find the owner of said knight
    return KNHT.knightOwner(CastleHoldingClanLeader);
  }

  function claimRewards() public {
    uint villageAmount = META.villageAmount();

    //Calculate reward
    uint paymentCycles = block.number - lastBlock();
    uint reward = getRewardPerBlock() * paymentCycles;
    //Assign rewards to village owners
    address[] memory owners = new address[](villageAmount + 1);
    uint256[] memory rewards = new uint256[](villageAmount + 1);
    for (uint v = 0; v < villageAmount; v++){
      owners[v] = META.villageOwner(v);
      rewards[v] = reward * (100 - getTax());
    }
    //Assign reward to castle holder clan leader
    owners[villageAmount] = CastleHolder();
    rewards[villageAmount] = reward * getTax();
    //Mint reward tokens
    META.SBT().mintBatch(owners, rewards);
    TRSR.layout().lastBlock = block.number;
  }

  function getRewardPerBlock() public view returns(uint) {
    return TRSR.rewardPerBlock();
  }

  function getTax() public view returns(uint) {
    return TRSR.castleTax();
  }

  function lastBlock() internal view returns(uint) {
    return TRSR.lastBlock();
  }

  function setTax(uint tax) external onlyCastleHolder(CastleHolder()) {
    require(tax <= 90, "TreasuryFacet: Can't set a tax above 90%");
    TRSR.layout().castleTax = tax;
    emit NewTaxSet(tax);
  }
}