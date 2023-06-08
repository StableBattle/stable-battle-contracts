// SPDX-License-Identifier: None
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import { DeployStableBattle } from "./DeployStableBattle.s.sol";
import { IBEER } from "../src/BEER/IBEER.sol";

contract DeployBEERStandalone is Script, DeployStableBattle {
  function run() external returns(IBEER) {
    //read env variables and choose EOA for transaction signing
    uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
    address deployerAddress = vm.envAddress("PUBLIC_KEY");

    vm.startBroadcast(deployerPrivateKey);

    IBEER BEER = deployBEER(deployerAddress, bytes32(type(uint256).max - 3));

    vm.stopBroadcast();

    console2.log("BEER Address: ", address(BEER));

    return BEER;
  }
}