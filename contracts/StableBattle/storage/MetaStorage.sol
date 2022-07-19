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

enum Pool {
  NONE,
  AAVE,
  TEST
}

enum Coin {
  NONE,
  USDT,
  USDC,
  TEST
}

library MetaStorage {
  struct State {
    // StableBattle EIP20 Token address
    address SBT;
    // StableBattle EIP721 Village address
    address SBV;

    mapping (Pool => address) pool;
    mapping (Coin => address) coin;
    mapping (Pool => mapping (Coin => bool)) compatible;
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
    return IERC20(MetaStorage.state().coin[Coin.USDT]);
  }

  function USDC() internal view virtual returns (IERC20) {
    return IERC20(MetaStorage.state().coin[Coin.USDC]);
  }

  function AAVE() internal view virtual returns (IPool) {
    return IPool(MetaStorage.state().pool[Pool.AAVE]);
  }

  function COIN(Coin coin) internal view virtual returns (IERC20) {
    return IERC20(MetaStorage.state().coin[coin]);
  }

  function PoolAddress(Pool pool) internal view virtual returns (address) {
    return MetaStorage.state().pool[pool];
  }

  function PoolAndCoinCompatibility(Pool p, Coin c) internal view returns (bool) {
    return MetaStorage.state().compatible[p][c];
  }
}

abstract contract MetaModifiers {
  function isVaildPool(Pool pool) internal view virtual returns(bool) {
    return pool != Pool.NONE ? true : false;
  }

  modifier ifIsVaildPool(Pool pool) {
    require(isVaildPool(pool), "MetaModifiers: This is not a valid pool");
    _;
  }

  function isValidCoin(Coin coin) internal view virtual returns(bool) {
    return coin != Coin.NONE ? true : false;
  }

  modifier ifIsValidCoin(Coin coin) {
    require(isValidCoin(coin), "MetaModifiers: This is not a valid coin");
    _;
  }

  function isCompatible(Pool p, Coin c) internal view virtual returns(bool) {
    return MetaStorage.state().compatible[p][c];
  }

  modifier ifIsCompatible(Pool p, Coin c) {
    require(isCompatible(p, c), "MetaModifiers: This token is incompatible with this pool");
    _;
  }

  function isSBV() internal view virtual returns(bool) {
    return MetaStorage.state().SBV == msg.sender;
  }

  modifier ifIsSBV {
    require(isSBV(), "MetaModifiers: can only be called by SBV");
    _;
  }

  function isSBT() internal view virtual returns(bool) {
    return MetaStorage.state().SBT == msg.sender;
  }

  modifier ifIsSBT {
    require(isSBT(),
      "MetaModifiers: can only be called by SBT");
    _;
  }

  function isSBD() internal view virtual returns(bool) {
    return address(this) == msg.sender;
  }

  modifier ifIsSBV {
    require(isSBV(), "MetaModifiers: can only be called by StableBattle");
    _;
  }
}
