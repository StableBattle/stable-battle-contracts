// SPDX-License-Identifier: Unlicensed

pragma solidity ^0.8.0;

library TreasuryStorage {
  struct Layout {
    uint castleTax;
    uint lastBlock;
    uint rewardPerBlock;
  }

  bytes32 internal constant STORAGE_SLOT = keccak256("Treasury.storage");

  function layout() internal pure returns (Layout storage l) {
    bytes32 slot = STORAGE_SLOT;
    assembly {
      l.slot := slot
    }
  }

  function castleTax() internal view returns(uint) {
    return layout().castleTax;
  }
  
  function lastBlock() internal view returns(uint) {
    return layout().lastBlock;
  }

  function rewardPerBlock() internal view returns(uint) {
    return layout().rewardPerBlock;
  }
}

contract TreasuryModifiers {
  modifier onlyCastleHolder(address castleHolderAddress) {
    require(msg.sender == castleHolderAddress,
      "TreasuryFacet: Only CastleHolder can use this function");
    _;
  }
}