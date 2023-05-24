// SPDX-License-Identifier: None
pragma solidity ^0.8.0;

import { Script } from "../lib/forge-std/src/Script.sol";
import { strings } from "solidity-stringutils/strings.sol";

contract VerifyEtherscan is Script {
  using strings for *;

  // return array of function selectors for given facet name
  function verifyContract(address _contract)
    internal
    returns (bytes4[] memory selectors)
  {}
}