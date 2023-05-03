// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.0;

import { IDiamondCut } from "../Facets/DiamondCut/IDiamondCut.sol";
import { IDiamondLoupe } from "../Facets/DiamondLoupe/IDiamondLoupe.sol";
import { IERC173 as IOwnership } from "../Facets/Ownership/IERC173.sol";
import { IItems } from "../Facets/Items/IItems.sol";
import { IClan } from "../Facets/Clan/IClan.sol";
import { IKnight } from "../Facets/Knight/IKnight.sol";
import { ISBVHook } from "../Facets/SBVHook/ISBVHook.sol";
import { ITreasury } from "../Facets/Treasury/ITreasury.sol";
import { IGear } from "../Facets/Gear/IGear.sol";
import { IEtherscan } from "../Facets/Etherscan/EtherscanFacet.sol";
import { IDebug } from "../Facets/Debug/IDebug.sol";
import { IAccessControl } from "../Facets/AccessControl/IAccessControl.sol";
import { ISiege } from "../Facets/Siege/ISiege.sol";
import { ConfigEvents } from "../Init&Updates/ConfigEvents.sol";

interface IStableBattle is
  IDiamondCut,
  IDiamondLoupe,
  IOwnership,
  IItems,
  IClan,
  IKnight,
//ISBVHook,
//ITreasury,
//IGear,
  IEtherscan,
  IDebug,
  IAccessControl,
  ISiege,
  ConfigEvents
{}