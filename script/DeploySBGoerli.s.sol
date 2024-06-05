// SPDX-License-Identifier: None
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import {DeployStableBattle} from "./DeployStableBattle.s.sol";
import {IStableBattle} from "../src/StableBattle/Meta/IStableBattle.sol";
import {IBEER} from "../src/BEER/IBEER.sol";
import {ISBV} from "../src/SBV/ISBV.sol";

contract DeploySBGoerli is Script, DeployStableBattle {
    bytes32 constant salt = bytes32(uint256(161));

    function run() external {
        //read env variables and choose EOA for transaction signing
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address deployerAddress = vm.envAddress("PUBLIC_KEY");

        vm.startBroadcast(deployerPrivateKey);

        (IStableBattle StableBattle, IBEER BEER, ISBV SBV) = deployStableBattle(deployerAddress, salt);

        vm.stopBroadcast();

        //check addresses
        console2.log("StableBattle Address: ", address(StableBattle));
        console2.log("BEER Address: ", address(BEER));
        console2.log("SBV Address: ", address(SBV));
    }
}
