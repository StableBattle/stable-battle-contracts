// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.0;

import { UpgradeableProxyOwnable } from "solidstate-solidity/proxy/upgradeable/UpgradeableProxyOwnable.sol";
import { ERC20MetadataStorage } from "solidstate-solidity/token/ERC20/metadata/ERC20MetadataStorage.sol";

contract BEERProxy is UpgradeableProxyOwnable {  
  constructor(address owner) {
  //Init ERC20
    ERC20MetadataStorage.layout().name = "BEER";
    ERC20MetadataStorage.layout().symbol = "BEER";
    ERC20MetadataStorage.layout().decimals = 18;
  //Set owner
    _transferOwnership(owner);
  }

  receive() external payable {}
}