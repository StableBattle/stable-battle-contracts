// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.0;

import { StorageSlot } from "@openzeppelin/contracts/utils/StorageSlot.sol";
import { Address } from "@openzeppelin/contracts/utils/Address.sol";
import { LibDiamond } from "../../Diamond/LibDiamond.sol";

contract EtherscanFacet {

  bytes32 internal constant _IMPLEMENTATION_SLOT = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;

  function setDummyImplementation(address newImplementation) external onlyOwner {
    require(Address.isContract(newImplementation), "ERC1967: new implementation is not a contract");
    StorageSlot.getAddressSlot(_IMPLEMENTATION_SLOT).value = newImplementation;
    emit DummyUpgraded(newImplementation);
  }

  function getDummyImplementation() external view returns (address) {
    return StorageSlot.getAddressSlot(_IMPLEMENTATION_SLOT).value;
  }

  modifier onlyOwner() {
    LibDiamond.enforceIsContractOwner();
    _;
  }

  event DummyUpgraded(address newImplementation);
}