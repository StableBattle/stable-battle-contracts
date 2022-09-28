// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.0;

import { IDiamondLoupe } from "./IDiamondLoupe.sol";
import { IERC165 } from "openzeppelin-contracts/interfaces/IERC165.sol";

contract DiamondLoupeFacetDummy is IDiamondLoupe, IERC165 {
    function facets() external override view returns (Facet[] memory facets_) {}

    function facetFunctionSelectors(address _facet) external override view returns (bytes4[] memory _facetFunctionSelectors) {}

    function facetAddresses() external override view returns (address[] memory facetAddresses_) {}

    function facetAddress(bytes4 _functionSelector) external override view returns (address facetAddress_) {}
    
    function supportsInterface(bytes4 _interfaceId) external virtual override view returns (bool) {}
}
