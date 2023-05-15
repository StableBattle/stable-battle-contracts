// SPDX-License-Identifier: None
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import { DeployStableBattle } from "./DeployStableBattle.s.sol";
import { IStableBattle } from "../src/StableBattle/Meta/IStableBattle.sol";
import { IBEER } from "../src/BEER/IBEER.sol";
import { ISBV } from "../src/SBV/ISBV.sol";

contract DeploySBGoerli is Script, DeployStableBattle {
  function run() external {
    //read env variables and choose EOA for transaction signing
    uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
    address deployerAddress = vm.envAddress("PUBLIC_KEY");

    vm.startBroadcast(deployerPrivateKey);

    (IStableBattle StableBattle, IBEER BEER, ISBV SBV ) = deployStableBattle(deployerAddress, 0);

    vm.stopBroadcast();

    //check addresses
    console2.log("Real Diamond address: ", address(StableBattle));
    console2.log("Diamond address from BEER: ", address(BEER.diamondAddress()));
    console2.log("Diamond address from SBV: ", address(SBV.diamondAddress()));
    console2.log("Real BEER address: ", address(BEER));
    console2.log("BEER address from Diamond: ", address(StableBattle.debugBEERAddress()));
    console2.log("Real SBV address: ", address(SBV));
    console2.log("SBV address from Diamond: ", address(StableBattle.debugSBVAddress()));
  }
}