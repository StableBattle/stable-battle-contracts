// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.0;

import { ItemsStorage } from "../storage/ItemsStorage.sol";

contract SBUpgrade {
  function SB_upgrade() external {
    ItemsStorage.state()._uri = "http://test1.stablebattle.io:5000/api/nft/";
  }
}
