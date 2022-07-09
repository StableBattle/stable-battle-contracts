// SPDX-License-Identifier: Unlicensed

pragma solidity ^0.8.0;

import { IERC20 } from "../../shared/interfaces/IERC20.sol";
import { IPool } from "@aave/core-v3/contracts/interfaces/IPool.sol";
import { ISBT } from "../../shared/interfaces/ISBT.sol";
import { ISBV } from "../../shared/interfaces/ISBV.sol";

library MetaStorage {
  struct State {
    // StableBattle EIP20 Token address
    ISBT SBT;
    // StableBattle EIP721 Village address
    ISBV SBV;

    IERC20 USDT;
    IPool AAVE;

    //Villages information (to reduce calls from Treasury)
    uint256 villageAmount;
    mapping (uint256 => address) villageOwner;
  }

  bytes32 internal constant STORAGE_SLOT = keccak256("Meta.storage");

  function state() internal pure returns (State storage l) {
    bytes32 slot = STORAGE_SLOT;
    assembly {
      l.slot := slot
    }
  }

  function SBDAddress() internal view returns (address){
    return address(this);
  }

  function SBT() internal view returns (ISBT) {
    return state().SBT;
  }

  function SBV() internal view returns (ISBV) {
    return state().SBV;
  }

  function USDT() internal view returns (IERC20) {
    return state().USDT;
  }

  function AAVE() internal view returns (IPool) {
    return state().AAVE;
  }

  function villageAmount() internal view returns(uint256) {
    return state().villageAmount;
  }
  
  function villageOwner(uint256 id) internal view returns(address) {
    return state().villageOwner[id];
  }
}
