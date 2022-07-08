// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.0;

import { knightType, Knight } from "../../StableBattle/storage/KnightStorage.sol";

interface IKnight {

  function mintKnight(knightType kt) external returns(uint256 id);

  function burnKnight (uint256 id) external;
  
  function knightCheck(uint256 kinghtId)  external view returns(Knight memory);

  function knightClan(uint256 kinghtId)  external view returns(uint256);

  function knightClanOwnerOf(uint256 kinghtId)  external view returns(uint256);

  function knightLevel(uint256 kinghtId)  external view returns(uint);

  function knightTypeOf(uint256 kinghtId)  external view returns(knightType);

  function knightOwner(uint256 knightId)  external view returns(address);

  function knightPrice(knightType kt) external view returns(uint256 price);
  
  event KnightMinted (uint knightId, address wallet, knightType kt);
  event KnightBurned (uint knightId, address wallet, knightType kt);
}
