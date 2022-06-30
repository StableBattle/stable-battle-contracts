// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.0;

import { MetaStorage as Ms} from "../storage/MetaStorage.sol";
import { TreasuryStorage as Ts} from "../storage/TreasuryStorage.sol";
import { ItemsStorage as Is } from "../storage/ItemsStorage.sol";
import { ClanStorage as Cs} from "../storage/ClanStorage.sol";
import { TournamentStorage as TMNTs} from "../storage/TournamentStorage.sol";

contract TreasuryFacet {
  using Ts for Ts.Layout;
  using Ms for Ms.Layout;
  using Is for Is.Layout;
  using Cs for Cs.Layout;
  using TMNTs for TMNTs.Layout;

  function CastleHolder() private view returns(address) {
    //Find owner of castle holding clan
      //Find the castle holding clan
    uint CastleHoldingClan = TMNTs.layout().CastleHolder;
      //Find the knight that leads said clan
    uint CastleHoldingClanLeader = Cs.layout().clan[CastleHoldingClan].owner;
      //Find the owner of said knight
    return Is.layout()._knightOwners[CastleHoldingClanLeader];
  }

  function claimRewards() public {
    uint lastBlock = Ts.layout().lastBlock;
    uint villageAmount = Ms.layout().villageAmount;

    //Calculate reward
    uint paymentCycles = block.number - lastBlock;
    uint reward = getRewardPerBlock() * paymentCycles;
    //Assign rewards to village owners
    address[] memory owners = new address[](villageAmount + 1);
    uint256[] memory rewards = new uint256[](villageAmount + 1);
    for (uint v = 0; v < villageAmount; v++){
      owners[v] = Ms.layout().villageOwner[v];
      rewards[v] = reward * (100 - getTax());
    }
    //Assign reward to castle holder clan leader
    owners[villageAmount] = CastleHolder();
    rewards[villageAmount] = reward * getTax();
    //Mint reward tokens
    Ms.layout().SBT.mintBatch(owners, rewards);
    Ts.layout().lastBlock = block.number;
  }

  function getRewardPerBlock() public view returns(uint) {
    return Ts.layout().rewardPerBlock;
  }

  function getTax() public view returns(uint) {
    return Ts.layout().castleTax;
  }

  function setTax(uint tax) external onlyCastleHolder {
    require(tax <= 90, "TreasuryFacet: Can't set a tax above 90%");
    Ts.layout().castleTax = tax;
    emit NewTaxSet(tax);
  }

  modifier onlyCastleHolder() {
    require(msg.sender == CastleHolder(),
      "TreasuryFacet: Only CastleHolder can use this function");
    _;
  }

  event BeneficiaryUpdated (uint village, address beneficiary);
  event NewTaxSet(uint tax);
}