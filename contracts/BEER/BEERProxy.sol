// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.0;

import { UpgradeableProxyOwnable } from "@solidstate/contracts/proxy/upgradeable/UpgradeableProxyOwnable.sol";
import { ERC20MetadataStorage } from "@solidstate/contracts/token/ERC20/metadata/ERC20MetadataStorage.sol";
import { BEERStorage } from "./BEERStorage.sol";

contract BEERProxy is UpgradeableProxyOwnable {
  using ERC20MetadataStorage for ERC20MetadataStorage.Layout;
  
  constructor(address implementation, address owner, address diamond) {
  //Init ERC20
    ERC20MetadataStorage.Layout storage l = ERC20MetadataStorage.layout();

    l.setName("BEER");
    l.setSymbol("BEER");
    l.setDecimals(18);
  //Set implementation
    _setImplementation(implementation);
  //Set owner
    _transferOwnership(owner);
  //Set StableBattle address
    BEERStorage.state().SBD = diamond;
  }

  receive() external payable {}
}