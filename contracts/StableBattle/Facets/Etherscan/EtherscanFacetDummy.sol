// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.0;

contract EtherscanFacetDummy {
  function setDummyImplementation(address newImplementation) external {}

  function getDummyImplementation() external view returns (address) {}

  event DummyUpgraded(address newImplementation);
}