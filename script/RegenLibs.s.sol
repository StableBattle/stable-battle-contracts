// SPDX-License-Identifier: None
pragma solidity ^0.8.0;

import { DiamondCutFacet } from "../src/StableBattle/Facets/DiamondCut/DiamondCutFacet.sol";
import { Diamond } from "../src/StableBattle/Diamond/Diamond.sol";

import { BEERProxy } from "../src/BEER/BEERProxy.sol";

import { SBVProxy } from "../src/SBV/SBVProxy.sol";

import { Script } from "../lib/forge-std/src/Script.sol";
import { strings } from "solidity-stringutils/strings.sol";
import { Strings } from "openzeppelin-contracts/utils/Strings.sol";
import { console2 } from  "forge-std/console2.sol";

contract RegenLibs is Script {
  using strings for *;

  function run() public {
    uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
    address deployerAddress = vm.envAddress("PUBLIC_KEY");

    vm.startBroadcast(deployerPrivateKey);
    //Precalc StableBattle Diamond address
    DiamondCutFacet diamondCutFacet = new DiamondCutFacet{salt: 0}();
    Diamond StableBattle = new Diamond{salt: 0}(deployerAddress, address(diamondCutFacet));
    updateAddressLib(address(StableBattle), "Diamond");
    //Precalc BEER address
    BEERProxy BEER = new BEERProxy{salt: 0}(address(deployerAddress));
    updateAddressLib(address(BEER), "BEER");
    //Precalc SBV address
    SBVProxy SBV = new SBVProxy{salt: 0}(address(deployerAddress));
    updateAddressLib(address(SBV), "SBV");

    console2.log("StableBattle address: ", address(StableBattle));
    console2.log("BEER address: ", address(BEER));
    console2.log("SBV address: ", address(SBV));

  //updateAddressLib(address(StableBattle), "Diamond");
  }

  function formAddressLine(address newAddress, string memory libName) private pure returns (string memory addressLine) {
    strings.slice memory beginLine = "  address internal constant ".toSlice();
    strings.slice memory libNameSlice = libName.toSlice();
    strings.slice memory middleLine = "Address = ".toSlice();
    strings.slice memory newAddressSlice = vm.toString(newAddress).toSlice();
    strings.slice memory endLine = ";".toSlice();
    addressLine = beginLine.concat(libNameSlice).toSlice().concat(middleLine).toSlice().concat(newAddressSlice).toSlice().concat(endLine);
  //console2.log("Address line: ", addressLine);
  }

  function formLibPath(string memory libName) private pure returns(string memory libPath) {
    strings.slice memory beginPath = "src/StableBattle/Init&Updates/".toSlice();
    strings.slice memory libNameSlice = libName.toSlice();
    strings.slice memory endPath = "AddressLib.sol".toSlice();
    libPath = beginPath.concat(libNameSlice).toSlice().concat(endPath);
  //console2.log("Lib path: ", libPath);
  }

  function formSolFileIntro(string memory libName) private pure returns(string memory solFileIntro) {
    strings.slice memory beginIntro = "// SPDX-License-Identifier: None\n\npragma solidity ^0.8.0;\n\nlibrary ".toSlice();
    strings.slice memory libNameSlice = libName.toSlice();
    strings.slice memory endIntro = "AddressLib {\n".toSlice();
    solFileIntro = beginIntro.concat(libNameSlice).toSlice().concat(endIntro);
  //console2.log("Sol file intro: ", solFileIntro);
  }

  function updateAddressLib(address newAddress, string memory libName) public {
    // Genereate sol file intro
    string memory solFileIntro = formSolFileIntro(libName);
    // Generate address line
    string memory addressLine = formAddressLine(newAddress, libName);
    // Generate path to lib
    string memory libPath = formLibPath(libName);
    vm.writeFile(libPath, solFileIntro);
    vm.writeLine(libPath, addressLine);
    vm.writeLine(libPath, "}");
    vm.closeFile(libPath);
  }  
}