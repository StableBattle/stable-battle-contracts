// SPDX-License-Identifier: Unlicensed

pragma solidity ^0.8.0;

import { IERC20 } from "../../shared/interfaces/IERC20.sol";
import { IPool } from "@aave/core-v3/contracts/interfaces/IPool.sol";
import { ISBT } from "../../shared/interfaces/ISBT.sol";
import { ISBV } from "../../shared/interfaces/ISBV.sol";
import { IClan } from "../../shared/interfaces/IClan.sol";
import { IForge } from "../../shared/interfaces/IForge.sol";
import { IGear } from "../../shared/interfaces/IGear.sol";
import { IItems } from "../../shared/interfaces/IItems.sol";
import { IKnight } from "../../shared/interfaces/IKnight.sol";
import { ISBVHook } from "../../shared/interfaces/ISBVHook.sol";
import { ITournament } from "../../shared/interfaces/ITournament.sol";
import { ITreasury } from "../../shared/interfaces/ITreasury.sol";

library MetaStorage {
  struct State {
    // StableBattle EIP20 Token address
    address SBT;
    // StableBattle EIP721 Village address
    address SBV;

    address USDT;
    address AAVE;
  }

  bytes32 internal constant STORAGE_SLOT = keccak256("Meta.storage");

  function state() internal pure returns (State storage l) {
    bytes32 slot = STORAGE_SLOT;
    assembly {
      l.slot := slot
    }
  }
}

abstract contract InternalCalls {
  function ClanFacet() internal view virtual returns (IClan) {
    return IClan(address(this));
  }

  function ForgeFacet() internal view virtual returns (IForge) {
    return IForge(address(this));
  }

  function GearFacet() internal view virtual returns (IGear) {
    return IGear(address(this));
  }

  function ItemsFacet() internal view virtual returns (IItems) {
    return IItems(address(this));
  }

  function KnightFacet() internal view virtual returns (IKnight) {
    return IKnight(address(this));
  }

  function SBVHookFacet() internal view virtual returns (ISBVHook) {
    return ISBVHook(address(this));
  }

  function TournamentFacet() internal view virtual returns (ITournament) {
    return ITournament(address(this));
  }

  function TreasuryFacet() internal view virtual returns (ITreasury) {
    return ITreasury(address(this));
  }
}

abstract contract ExternalCalls {
  function SBT() internal view virtual returns (ISBT) {
    return ISBT(MetaStorage.state().SBT);
  }

  function SBV() internal view virtual returns (ISBV) {
    return ISBV(MetaStorage.state().SBV);
  }

  function USDT() internal view virtual returns (IERC20) {
    return IERC20(MetaStorage.state().USDT);
  }

  function AAVE() internal view virtual returns (IPool) {
    return IPool(MetaStorage.state().AAVE);
  }
}

abstract contract MetaModifiers {
  modifier onlySBV {
    require(MetaStorage.state().SBV == msg.sender,
      "MetaModifiers: can only be called by SBV");
    _;
  }

  modifier onlySBT {
    require(MetaStorage.state().SBT == msg.sender,
      "MetaModifiers: can only be called by SBT");
    _;
  }
}
