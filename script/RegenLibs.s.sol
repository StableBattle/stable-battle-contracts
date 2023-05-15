// SPDX-License-Identifier: None
pragma solidity ^0.8.0;

import { Script } from "../lib/forge-std/src/Script.sol";
import { strings } from "solidity-stringutils/strings.sol";
import { Strings } from "openzeppelin-contracts/utils/Strings.sol";
import { console2 } from  "forge-std/console2.sol";

contract RegenLibs is Script {
  using strings for *;

  function formAddressLine(address newAddress, string memory libName) private pure returns (string memory addressLine) {
    strings.slice memory beginLine = "'6s/.*/  address internal constant ".toSlice();
    strings.slice memory libNameSlice = libName.toSlice();
    strings.slice memory middleLine = "Address = address(".toSlice();
    strings.slice memory newAddressSlice = Strings.toHexString(newAddress).toSlice();
    strings.slice memory endLine = ");/'".toSlice();
    addressLine = beginLine.concat(libNameSlice).toSlice().concat(middleLine).toSlice().concat(newAddressSlice).toSlice().concat(endLine);
  //console2.log("Address line: ", addressLine);
  }

  function formLibPath(string memory libName) private pure returns(string memory libPath) {
    strings.slice memory beginPath = "'src/StableBattle/Init&Updates/".toSlice();
    strings.slice memory libNameSlice = libName.toSlice();
    strings.slice memory endPath = "AddressLib.sol'".toSlice();
    libPath = beginPath.concat(libNameSlice).toSlice().concat(endPath);
  //console2.log("Lib path: ", libPath);
  }

  function updateAddressLib(address newAddress, string memory libName) public {
    // Generate replacer line
    string memory replacerLine = formAddressLine(newAddress, libName);
    // Generate path to lib
    string memory libPath = formLibPath(libName);
    // Replace address line in respective lib
    string[] memory cmd = new string[](9);
    cmd[0] = "sed";
    cmd[1] = "-e";
    cmd[2] = replacerLine;
    cmd[3] = "-i";
    cmd[4] = "''";
    cmd[5] = libPath;
    if(true) {
      string memory command = "";
      for(uint i = 0; i < cmd.length; i++) {
        command = command.toSlice().concat(cmd[i].toSlice()).toSlice().concat(" ".toSlice());
      }
      console2.log("Command: ", command);
    }
    bytes memory res = vm.ffi(cmd);
    console2.log("sed result: ", string(res));
    /*
    if (res.length > 0) {
      string memory st = string(res);
      revert(st);
    }
    // Rebuild contracts with updated libs
    string[] memory cmd2 = new string[](2);
    cmd2[0] = "forge";
    cmd2[1] = "build";
    bytes memory res2 = vm.ffi(cmd2);
    string memory st2 = string(res2);
    console2.log("forge build result: ", st2);
    */
  }
}