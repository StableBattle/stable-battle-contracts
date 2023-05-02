// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.0;

import { UpgradeableProxyOwnable } from "@solidstate/contracts/proxy/upgradeable/UpgradeableProxyOwnable.sol";
import { ERC721MetadataStorage } from "@solidstate/contracts/token/ERC721/metadata/ERC721MetadataStorage.sol";

contract SBVProxy is UpgradeableProxyOwnable {
  using ERC721MetadataStorage for ERC721MetadataStorage.Layout;

  constructor(address implementation, address owner) {
  //Init ERC20
    ERC721MetadataStorage.Layout storage l = ERC721MetadataStorage.layout();

    l.name = "StableBattle Villages";
    l.symbol = "SBV";
    l.baseURI = "";
  //Set implementation
    _setImplementation(implementation);
  //Set owner
    _transferOwnership(owner);
  }

  receive() external payable {}
}