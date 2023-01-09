// SPDX-License-Identifier: None
pragma solidity ^0.8.0;

interface IDiamondFactory {
  function mintDiamond(bytes32 _salt, address DiamondCut) external returns(address);

  error AdressessDontMatch(address predictedAddress, address realAddress);
}