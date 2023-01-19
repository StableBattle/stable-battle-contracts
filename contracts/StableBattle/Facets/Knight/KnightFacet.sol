// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.10;

import { Coin, Pool, Knight } from "../../Meta/DataStructures.sol";
import { IKnight } from "../Knight/IKnight.sol";

import { KnightInternal } from "../Knight/KnightInternal.sol";
import { ItemsModifiers } from "../Items/ItemsModifiers.sol";
import { KnightGettersExternal } from "../Knight/KnightGetters.sol";

contract KnightFacet is 
  IKnight,
  KnightGettersExternal,
  ItemsModifiers,
  KnightInternal
{
  function mintKnight(Pool p, Coin c)
    external
    ifIsValidCoin(c)
    ifIsVaildPool(p)
    ifIsCompatible(p, c)
  {
    _mintKnight(p, c);
  }

  function burnKnight(uint256 knightId)
    external
  //ifOwnsItem(knightId)
    ifIsKnight(knightId)
    ifIsVaildPool(_knightPool(knightId))
    ifIsValidCoin(_knightCoin(knightId))
    ifIsCompatible(_knightPool(knightId), _knightCoin(knightId))
  {
    _burnKnight(knightId);
  }
}