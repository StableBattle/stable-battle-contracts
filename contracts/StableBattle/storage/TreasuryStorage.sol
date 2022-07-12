// SPDX-License-Identifier: Unlicensed

pragma solidity ^0.8.0;

library TreasuryStorage {
  struct State {
    uint8 castleTax;
    uint lastBlock;
    uint rewardPerBlock;

    //Villages information
    uint256 villageAmount;
    mapping (uint256 => address) villageOwner;
  }

  bytes32 internal constant STORAGE_SLOT = keccak256("Treasury.storage");

  function state() internal pure returns (State storage l) {
    bytes32 slot = STORAGE_SLOT;
    assembly {
      l.slot := slot
    }
  }
}

abstract contract TreasuryGetters {
  function castleTax() internal view virtual returns(uint) {
    return TreasuryStorage.state().castleTax;
  }
  
  function lastBlock() internal view virtual returns(uint) {
    return TreasuryStorage.state().lastBlock;
  }

  function rewardPerBlock() internal view virtual returns(uint) {
    return TreasuryStorage.state().rewardPerBlock;
  }

  function villageAmount() internal view virtual returns(uint256) {
    return TreasuryStorage.state().villageAmount;
  }

  function villageOwner(uint256 villageId) internal view virtual returns(address) {
    return TreasuryStorage.state().villageOwner[villageId];
  }
}

contract TreasuryModifiers {
  modifier onlyCastleHolder(address castleHolderAddress) {
    require(msg.sender == castleHolderAddress,
      "TreasuryFacet: Only CastleHolder can use this function");
    _;
  }
}