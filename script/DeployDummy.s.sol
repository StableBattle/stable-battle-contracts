// SPDX-License-Identifier: None
pragma solidity ^0.8.0;

import { Script } from "../lib/forge-std/src/Script.sol";
import { StableBattleDummy } from "../src/StableBattle/Facets/Etherscan/StableBattleDummy.sol";
import { IStableBattle } from "../src/StableBattle/Meta/IStableBattle.sol";
import { DiamondAddressLib } from "../src/StableBattle/Init&Updates/DiamondAddressLib.sol";
import { console2 } from  "forge-std/console2.sol";

contract DeployDummy is Script {
  function run() external {
    //read env variables and choose EOA for transaction signing
    uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

    vm.startBroadcast(deployerPrivateKey);
    IStableBattle dummy = new StableBattleDummy();
    IStableBattle StableBattle = IStableBattle(DiamondAddressLib.DiamondAddress);
    StableBattle.setDummyImplementation(address(dummy));
    console2.log("Dummy address: ", address(dummy));
    vm.stopBroadcast();
  }
}