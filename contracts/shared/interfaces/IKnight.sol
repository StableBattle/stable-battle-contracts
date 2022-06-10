// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.10;

import { knightType } from "../../StableBattle/libraries/LibAppStorage.sol";

interface IKnight {

  function mint_AAVE_knight() external returns(uint256);

  function mint_OTHER_knight() external;

  function burn_knight (uint256 item_id) external;
  
  event KnightMinted (uint item_id, address wallet, knightType kt);
  event KnightBurned (uint item_id, address wallet, knightType kt);
}
