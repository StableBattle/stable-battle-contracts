// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.0;

import { DiamondCutFacetDummy } from "../dummies/DiamondCutFacetDummy.sol";
import { DiamondLoupeFacetDummy } from "../dummies/DiamondLoupeFacetDummy.sol";
import { OwnershipFacetDummy } from "../dummies/OwnershipFacetDummy.sol";
import { ItemsFacetDummy } from "../dummies/ItemsFacetDummy.sol";
import { ClanFacetDummy } from "../dummies/ClanFacetDummy.sol";
import { ForgeFacetDummy } from "../dummies/ForgeFacetDummy.sol";
import { KnightFacetDummy } from "../dummies/KnightFacetDummy.sol";
import { SBVHookFacetDummy } from "../dummies/SBVHookFacetDummy.sol";
import { TournamentFacetDummy } from "../dummies/TournamentFacetDummy.sol";
import { TreasuryFacetDummy } from "../dummies/TreasuryFacetDummy.sol";
import { GearFacetDummy } from "../dummies/GearFacetDummy.sol";

/*
  This is a dummy implementation of StableBattle contracts.
  This contract is needed due to Etherscan proxy recognition difficulties.
  This implementation will be updated alongside StableBattle Diamond updates
*/

contract StableBattleDummy is DiamondCutFacetDummy,
                              DiamondLoupeFacetDummy,
                              OwnershipFacetDummy,
                              ItemsFacetDummy,
                              ClanFacetDummy,
                              ForgeFacetDummy,
                              KnightFacetDummy,
                              SBVHookFacetDummy,
                              TournamentFacetDummy,
                              TreasuryFacetDummy,
                              GearFacetDummy {}