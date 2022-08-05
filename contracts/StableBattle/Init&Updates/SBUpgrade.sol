// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.0;

import { TreasuryStorage } from "../Treasury/TreasuryStorage.sol";

contract SBUpgrade {
  using TreasuryStorage for TreasuryStorage.State;

  struct Args {
    uint8 castleTax;
    uint256 rewardPerBlock;
  }

  function SB_upgrade(Args memory _args) external {
    //Treasury Facet
      TreasuryStorage.state().castleTax = _args.castleTax;
      TreasuryStorage.state().rewardPerBlock = _args.rewardPerBlock;
  }
}
