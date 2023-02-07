// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.0;

import { IEtherscan } from "../Etherscan/EtherscanFacet.sol";

contract EtherscanFacetDummy is IEtherscan {
  function setDummyImplementation(address newImplementation) external {}
  function getDummyImplementation() external view returns (address) {}
}