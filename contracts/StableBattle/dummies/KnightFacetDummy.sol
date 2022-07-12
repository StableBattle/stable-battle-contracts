// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.0;

import { IKnight } from "../../shared/interfaces/IKnight.sol";

import { knightType, Knight} from "../storage/KnightStorage.sol";

contract KnightFacetDummy is IKnight {

//Knight Facet
  function mintKnight(knightType kt) external{}

  function burnKnight (uint256 id) external{}

//Knight Getters
  function getKnightCheck(uint256 kinghtId)  external view returns(Knight memory){}

  function getKnightClan(uint256 kinghtId)  external view returns(uint256){}

  function getKnightClanOwnerOf(uint256 kinghtId)  external view returns(uint256){}

  function getKnightLevel(uint256 kinghtId)  external view returns(uint){}

  function getKnightTypeOf(uint256 kinghtId)  external view returns(knightType){}

  function getKnightOwner(uint256 knightId)  external view returns(address){}

  function getKnightPrice(knightType kt) external view returns(uint256 price){}
}