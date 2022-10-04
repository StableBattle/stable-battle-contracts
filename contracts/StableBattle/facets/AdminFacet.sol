// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.0;

import { MetaStorage, MetaModifiers } from "../storage/MetaStorage.sol";
import { LibDiamond } from "../../shared/libraries/LibDiamond.sol";

contract AdminFacet is MetaModifiers {
  function addAdmin(address newAdmin) external ifIsAdmin {
    MetaStorage.state().admins[newAdmin] = true;
  }

  function removeAdmin(address oldAdmin) external ifIsAdmin {
    MetaStorage.state().admins[oldAdmin] = false;
  }
}