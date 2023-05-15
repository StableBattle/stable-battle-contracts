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

contract GenerateDiamondAddressLib is Script, RegenLibs {
  function run() public {
    uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
    address deployerAddress = vm.envAddress("PUBLIC_KEY");

    vm.broadcast(deployerPrivateKey);
    //Precalc diamondCutFacet address
    DiamondCutFacet diamondCutFacet = new DiamondCutFacet{salt: 0}();
    Diamond StableBattle = new Diamond{salt: 0}(deployerAddress, address(diamondCutFacet));
    vm.stopBroadcast();

    console2.log("Diamond address: ", address(StableBattle));

  //updateAddressLib(address(StableBattle), "Diamond");
  }
}

contract GenerateBEERAddressLib is Script, RegenLibs {
  function run() public {
    uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
    address deployerAddress = vm.envAddress("PUBLIC_KEY");

    vm.broadcast(deployerPrivateKey);
    //Precalc BEER Implementation address
    BEERImplementation BEERImplementationContract = new BEERImplementation{salt: 0}();

    //Precalc BEER Proxy address
    BEERProxy BEERProxyContract = new BEERProxy{salt: 0}(address(BEERImplementationContract), deployerAddress);
    vm.stopBroadcast();

    console2.log("BEER address: ", address(BEERProxyContract));

  //updateAddressLib(address(BEERProxyContract), "BEER");
  }
}

contract GenerateSBVAddressLib is Script, RegenLibs {
  function run() public {
    uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
    address deployerAddress = vm.envAddress("PUBLIC_KEY");

    vm.broadcast(deployerPrivateKey);
    //Precalc SBV Implementation address
    SBVImplementation SBVImplementationContract = new SBVImplementation{salt: 0}();

    //Precalc SBV Proxy address
    SBVProxy SBVProxyContract = new SBVProxy{salt: 0}(address(SBVImplementationContract), deployerAddress);
    vm.stopBroadcast();

    console2.log("Villages address: ", address(SBVProxyContract));

  //updateAddressLib(address(SBVProxyContract), "SBV");
  }
}