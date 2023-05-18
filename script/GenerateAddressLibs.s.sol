// SPDX-License-Identifier: None
pragma solidity ^0.8.0;

import { DiamondCutFacet } from "../src/StableBattle/Facets/DiamondCut/DiamondCutFacet.sol";
import { Diamond } from "../src/StableBattle/Diamond/Diamond.sol";

import { BEERImplementation } from "../src/BEER/BEERImplementation.sol";
import { BEERProxy } from "../src/BEER/BEERProxy.sol";

import { SBVImplementation } from "../src/SBV/SBVImplementation.sol";
import { SBVProxy } from "../src/SBV/SBVProxy.sol";

import { Script } from "forge-std/Script.sol";
import { RegenLibs } from  "./RegenLibs.s.sol";
import { console2 } from  "forge-std/console2.sol";

contract GenerateAddressLib is Script, RegenLibs {
  function run() public {
    uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
    address deployerAddress = vm.envAddress("PUBLIC_KEY");

    vm.startBroadcast(deployerPrivateKey);
    //Precalc StableBattle Diamond address
    DiamondCutFacet diamondCutFacet = new DiamondCutFacet{salt: 0}();
    Diamond StableBattle = new Diamond{salt: 0}(deployerAddress, address(diamondCutFacet));
    //Precalc BEER address
    BEERProxy BEER = new BEERProxy{salt: 0}(address(deployerAddress));
    //Precalc SBV address
    SBVProxy SBV = new SBVProxy{salt: 0}(address(deployerAddress));

    console2.log("StableBattle address: ", address(StableBattle));
    console2.log("BEER address: ", address(BEER));
    console2.log("SBV address: ", address(SBV));

  //updateAddressLib(address(StableBattle), "Diamond");
  }
}