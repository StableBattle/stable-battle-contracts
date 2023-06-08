// SPDX-License-Identifier: None
pragma solidity ^0.8.0;

import { BEERImplementation } from "../src/BEER/BEERImplementation.sol";
import { Script } from "forge-std/Script.sol";
import { LzChainIdsLib } from "../src/BEER/OFT/LzChainIdsLib.sol";

contract SetTrustedRemote is Script {
  uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
  address deployerAddress = vm.envAddress("PUBLIC_KEY");
  address BEERAddress = 0x4F12D5D6b380a839efC3428e7B7B4EBcFd04E5DD;
  BEERImplementation BEER = BEERImplementation(BEERAddress);

  function run() external {
    vm.startBroadcast(deployerPrivateKey);
    BEER.setTrustedRemote(
      LzChainIdsLib.goerliLzChainId,
      abi.encodePacked(address(BEER), address(BEER))
    );
    vm.stopBroadcast();
  }
}