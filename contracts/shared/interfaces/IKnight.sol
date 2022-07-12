// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.0;

import { knightType, Knight } from "../../StableBattle/storage/KnightStorage.sol";

interface IKnight {

//Knight Facet
  function mintKnight(knightType kt) external;

  function burnKnight (uint256 id) external;

//Knight Getters
  function getKnightCheck(uint256 kinghtId)  external view returns(Knight memory);

  function getKnightClan(uint256 kinghtId)  external view returns(uint256);

  function getKnightClanOwnerOf(uint256 kinghtId)  external view returns(uint256);

  function getKnightLevel(uint256 kinghtId)  external view returns(uint);

  function getKnightTypeOf(uint256 kinghtId)  external view returns(knightType);

  function getKnightOwner(uint256 knightId)  external view returns(address);

  function getKnightPrice(knightType kt) external view returns(uint256 price);
  
  event KnightMinted (uint knightId, address wallet, knightType kt);
  event KnightBurned (uint knightId, address wallet, knightType kt);
}
