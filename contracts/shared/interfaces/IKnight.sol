// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.0;

import { knightType, Knight } from "../../StableBattle/storage/KnightStorage.sol";

interface IKnight {

  function knightCheck(uint256 knightId) external view returns(Knight memory);

  function knightClan(uint256 knightId) external view returns(uint256);

  function knightClanOwnerOf(uint256 knightId) external view returns(uint256);

  function knightLevel(uint256 knightId) external view returns(uint);

  function knightTypeOf(uint256 knightId) external view returns(knightType);

  function knightPrice(knightType kt) external pure returns(uint256);

  function mintKnight(knightType kt) external returns(uint256);

  function burnKnight(uint256) external;
  
  event KnightMinted (uint knightId, address wallet, knightType kt);
  event KnightBurned (uint knightId, address wallet, knightType kt);
}
