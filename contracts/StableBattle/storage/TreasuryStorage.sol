// SPDX-License-Identifier: Unlicensed

pragma solidity ^0.8.0;

library TreasuryStorage {
  struct State {
    uint8 castleTax;
    uint lastBlock;
    uint rewardPerBlock;
  }

  bytes32 internal constant STORAGE_SLOT = keccak256("Treasury.storage");

  function state() internal pure returns (State storage l) {
    bytes32 slot = STORAGE_SLOT;
    assembly {
      l.slot := slot
    }
  }

  function castleTax() internal view returns(uint) {
    return state().castleTax;
  }
  
  function lastBlock() internal view returns(uint) {
    return state().lastBlock;
  }

  function rewardPerBlock() internal view returns(uint) {
    return state().rewardPerBlock;
  }
}

contract TreasuryModifiers {
  modifier onlyCastleHolder(address castleHolderAddress) {
    require(msg.sender == castleHolderAddress,
      "TreasuryFacet: Only CastleHolder can use this function");
    _;
  }
}