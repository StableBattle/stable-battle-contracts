// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.0;

import { MetaStorage as META } from "../storage/MetaStorage.sol";
import { TreasuryStorage as TRSR } from "../storage/TreasuryStorage.sol";
import { KnightStorage as KNHT } from "../storage/KnightStorage.sol";
import { ClanStorage as CLAN } from "../storage/ClanStorage.sol";
import { TournamentStorage as TMNT } from "../storage/TournamentStorage.sol";
import { ITreasury } from "../../shared/interfaces/ITreasury.sol";

contract TreasuryFacet is ITreasury {
  using TRSR for TRSR.Layout;
  using META for META.Layout;
  using KNHT for KNHT.Layout;
  using CLAN for CLAN.Layout;
  using TMNT for TMNT.Layout;

  function CastleHolder() private view returns(address) {
  //Find owner of castle holding clan
    //Find the castle holding clan
    uint CastleHoldingClan = TMNT.layout().CastleHolder;
    //Find the knight that leads that clan
    uint CastleHoldingClanLeader = CLAN.layout().clan[CastleHoldingClan].owner;
    //Find the owner of said knight
    return KNHT.layout().knight[CastleHoldingClanLeader].owner;
  }

  function claimRewards() public {
    uint lastBlock = TRSR.layout().lastBlock;
    uint villageAmount = META.layout().villageAmount;

    //Calculate reward
    uint paymentCycles = block.number - lastBlock;
    uint reward = getRewardPerBlock() * paymentCycles;
    //Assign rewards to village owners
    address[] memory owners = new address[](villageAmount + 1);
    uint256[] memory rewards = new uint256[](villageAmount + 1);
    for (uint v = 0; v < villageAmount; v++){
      owners[v] = META.layout().villageOwner[v];
      rewards[v] = reward * (100 - getTax());
    }
    //Assign reward to castle holder clan leader
    owners[villageAmount] = CastleHolder();
    rewards[villageAmount] = reward * getTax();
    //Mint reward tokens
    META.layout().SBT.mintBatch(owners, rewards);
    TRSR.layout().lastBlock = block.number;
  }

  function getRewardPerBlock() public view returns(uint) {
    return TRSR.layout().rewardPerBlock;
  }

  function getTax() public view returns(uint) {
    return TRSR.layout().castleTax;
  }

  function setTax(uint tax) external onlyCastleHolder {
    require(tax <= 90, "TreasuryFacet: Can't set a tax above 90%");
    TRSR.layout().castleTax = tax;
    emit NewTaxSet(tax);
  }

  modifier onlyCastleHolder() {
    require(msg.sender == CastleHolder(),
      "TreasuryFacet: Only CastleHolder can use this function");
    _;
  }
}