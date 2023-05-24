// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.0;

import { Coin, Pool, ClanRole } from "../../Meta/DataStructures.sol";
import { IKnight } from "../Knight/IKnight.sol";

import { KnightInternal } from "../Knight/KnightInternal.sol";
import { ItemsModifiers } from "../Items/ItemsModifiers.sol";
import { MetaModifiers } from "../../Meta/MetaModifiers.sol";
import { KnightGettersExternal } from "../Knight/KnightGetters.sol";

contract KnightFacet is 
  IKnight,
  KnightGettersExternal,
  ItemsModifiers,
  MetaModifiers,
  KnightInternal
{
  function mintKnight(Pool p, Coin c)
    external
    ifIsCompatible(p, c)
    returns (uint256)
  {
    return _mintKnight(p, c);
  }

  function burnKnight(uint256 knightId, uint256 heirId)
    external
    ifOwnsItem(knightId)
    ifIsKnight(knightId)
    ifIsCompatible(_knightPool(knightId), _knightCoin(knightId))
  {
    //Leave or abandon clan
    uint256 clanId = _knightClan(knightId);
    uint256 leaderId = _clanLeader(clanId);
    if (clanId != 0 && leaderId != 0) {
      if (knightId == leaderId) {
        if(heirId != 0) {
          if(knightId == heirId) {
          //revert KnightFacet_CantAppointYourselfAsHeir(knightId);
            revert("KnightFacet: Can't appoint yourself as heir");
          }
          if(!isKnight(heirId)) {
          //revert KnightFacet_HeirIsNotKnight(heirId);
            revert("KnightFacet: Heir is not knight");
          }
          if(_knightClan(heirId) != clanId) {
          //revert KnightFacet_HeirIsNotInTheSameClan(clanId, heirId);
            revert("KnightFacet: Heir is not in the same clan");
          }
          _kick(knightId, clanId);
          _setClanRole(clanId, heirId, ClanRole.OWNER);
        } else {
          _abandonClan(clanId, knightId);
        }
      } else {
        _kick(knightId, clanId);
      }
    }
    //Burn knight
    _burnKnight(knightId);
  }
}