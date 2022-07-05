// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.0;

import { IDiamondCut } from "../../shared/interfaces/IDiamondCut.sol";

contract DiamondCutFacetDummy is IDiamondCut {
    function diamondCut(
        FacetCut[] calldata _diamondCut,
        address _init,
        bytes calldata _calldata
    ) external override {}
}
