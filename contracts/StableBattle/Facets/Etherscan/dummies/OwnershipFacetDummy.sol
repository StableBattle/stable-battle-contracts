// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { IERC173 } from "../../../../shared/interfaces/IERC173.sol";

contract OwnershipFacetDummy is IERC173 {
    function transferOwnership(address _newOwner) external override {}

    function owner() external override view returns (address owner_) {}
}
