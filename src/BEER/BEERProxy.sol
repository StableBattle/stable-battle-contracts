// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.0;

import { UpgradeableProxyOwnable } from "solidstate-solidity/proxy/upgradeable/UpgradeableProxyOwnable.sol";
import { ERC20MetadataStorage } from "solidstate-solidity/token/ERC20/metadata/ERC20MetadataStorage.sol";

contract BEERProxy is UpgradeableProxyOwnable {
  using ERC20MetadataStorage for ERC20MetadataStorage.Layout;
  
  constructor(address implementation, address owner) {
  //Init ERC20
    ERC20MetadataStorage.Layout storage l = ERC20MetadataStorage.layout();

    l.name = "BEER";
    l.symbol = "BEER";
    l.decimals = 18;
  //Set implementation
    _setImplementation(implementation);
  //Set owner
    _transferOwnership(owner);
  }

  receive() external payable {}
}