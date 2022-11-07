// SPDX-License-Identifier: None
pragma solidity ^0.8.0;

import { Diamond } from "../StableBattle/Diamond/Diamond.sol";
import { IDiamondFactory } from "./IDiamondFactory.sol";

contract DiamondFactory is IDiamondFactory {
  function mintDiamond(bytes32 _salt, address DiamondCut) external returns (address) {
    address predictedAddress = address(uint160(uint(keccak256(abi.encodePacked(
            bytes1(0xff),
            address(this),
            _salt,
            keccak256(abi.encodePacked(
                type(Diamond).creationCode,
                abi.encode(msg.sender, DiamondCut)
            ))
        )))));

    address realAddress = address(new Diamond{salt: _salt}(msg.sender, DiamondCut));
    if (realAddress == predictedAddress) {
      return realAddress;
    } else {
      revert AdressessDontMatch(predictedAddress, realAddress);
    }
  }
}