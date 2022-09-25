// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.0;

import { DiamondCutFacetDummy } from "../DiamondCut/DiamondCutFacetDummy.sol";
import { DiamondLoupeFacetDummy } from "../DiamondLoupe/DiamondLoupeFacetDummy.sol";
import { OwnershipFacetDummy } from "../Ownership/OwnershipFacetDummy.sol";
import { ItemsFacetDummy } from "../Items/ItemsFacetDummy.sol";
import { ClanFacetDummy } from "../Clan/ClanFacetDummy.sol";
import { KnightFacetDummy } from "../Knight/KnightFacetDummy.sol";
import { SBVHookFacetDummy } from "../SBVHook/SBVHookFacetDummy.sol";
import { TournamentFacetDummy } from "../Tournament/TournamentFacetDummy.sol";
import { TreasuryFacetDummy } from "../Treasury/TreasuryFacetDummy.sol";
import { GearFacetDummy } from "../Gear/GearFacetDummy.sol";
import { EtherscanFacetDummy } from "../Etherscan/EtherscanFacetDummy.sol";
import { DemoFightFacetDummy } from "../DemoFight/DemoFightFacetDummy.sol";

/*
  This is a dummy implementation of StableBattle contracts.
  This contract is needed due to Etherscan proxy recognition difficulties.
  This implementation will be updated alongside StableBattle Diamond updates.
  
  To get addresses of the real implementation code either use Louper.dev or look into scripts/config/(network)
*/

contract StableBattleDummy is 
  DiamondCutFacetDummy,
  DiamondLoupeFacetDummy,
  OwnershipFacetDummy,
  ItemsFacetDummy,
  ClanFacetDummy,
  KnightFacetDummy,
  SBVHookFacetDummy,
  TournamentFacetDummy,
  TreasuryFacetDummy,
  GearFacetDummy,
  EtherscanFacetDummy,
  DemoFightFacetDummy
{
  function supportsInterface(bytes4 interfaceId)
    external
    view
    override(DiamondLoupeFacetDummy, ItemsFacetDummy)
    returns (bool)
  {}
}