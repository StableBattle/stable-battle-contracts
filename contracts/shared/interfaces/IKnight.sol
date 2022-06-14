// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.0;

import { knightType } from "../../StableBattle/libraries/LibAppStorage.sol";

interface IKnight {

  function knightPrice() external pure returns(uint256);

  function mint_AAVE_knight() external returns(uint256);

  function mint_OTHER_knight() external returns(uint256);

  function burn_knight (uint256) external;
  
  event KnightMinted (uint item_id, address wallet, knightType kt);
  event KnightBurned (uint item_id, address wallet, knightType kt);
}
